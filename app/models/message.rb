class Message < ApplicationRecord
  belongs_to :channel, counter_cache: :messages_count
  belongs_to :user, counter_cache: :messages_count
  belongs_to :thread_root, class_name: 'Message', optional: true
  belongs_to :note, optional: true
  belongs_to :parent_message, class_name: 'Message', optional: true
  
  # Sharing relationships
  belongs_to :shared_from_message, class_name: 'Message', optional: true
  belongs_to :shared_from_channel, class_name: 'Channel', optional: true
  belongs_to :shared_by_user, class_name: 'User', optional: true
  
  has_many :thread_messages, class_name: 'Message', foreign_key: 'thread_root_id', dependent: :destroy
  has_many :reactions, class_name: 'MessageReaction', dependent: :destroy
  has_many :saved_messages, dependent: :destroy
  has_many :users_who_saved, through: :saved_messages, source: :user
  has_many :message_reads, dependent: :destroy
  has_many :readers, through: :message_reads, source: :user
  has_many :message_mentions, dependent: :destroy
  has_many :mentioned_users, through: :message_mentions, source: :user
  
  # File attachments
  has_many_attached :attachments
  
  # Validation: body is required unless attachments or note is present
  validates :body, presence: true, unless: :has_attachments_or_note?
  
  # File validations
  validate :validate_attachments
  validate :validate_note_workspace
  
  # Constants for file validation
  MAX_FILE_SIZE = 25.megabytes
  MAX_VIDEO_SIZE = 50.megabytes
  ALLOWED_FILE_TYPES = %w[
    image/jpeg image/jpg image/png image/gif image/webp
    video/mp4 video/mpeg video/quicktime video/x-msvideo video/x-ms-wmv video/webm
    application/pdf
    application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation
    text/plain
    application/zip application/x-rar-compressed
  ].freeze
  
  # Mark as read by the author when created
  after_create_commit { mark_as_read_by(user) }
  
  # Process mentions after message is created
  after_create_commit { process_mentions }
  
  # Broadcast deletion to all users in the channel
  after_destroy_commit { broadcast_remove }
  
  scope :root_messages, -> { where(thread_root_id: nil) }
  scope :thread_replies, -> { where.not(thread_root_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :pinned, -> { where(is_pinned: true).order(pinned_at: :desc) }
  
  def thread_root?
    thread_root_id.nil?
  end
  
  def has_thread?
    thread_messages.exists?
  end
  
  def pin!
    update(is_pinned: true, pinned_at: Time.current)
  end
  
  def unpin!
    update(is_pinned: false, pinned_at: nil)
  end
  
  def saved_by?(user)
    saved_messages.exists?(user: user)
  end
  
  def reacted_by?(user, emoji)
    reactions.exists?(user: user, emoji: emoji)
  end
  
  def read_by?(user)
    message_reads.exists?(user: user)
  end
  
  def mark_as_read_by(user)
    message_reads.find_or_create_by(user: user, read_at: Time.current)
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition where two requests try to create the same read record
    message_reads.find_by(user: user)
  end
  
  def unread_by_count
    channel.users.count - readers.count
  end
  
  def youtube_urls
    return [] unless body.present?
    
    # YouTube URL patterns with word boundaries
    patterns = [
      %r{((?:https?://)?(?:www\.)?youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})(?:&[^\s]*)?)},
      %r{((?:https?://)?(?:www\.)?youtu\.be/([a-zA-Z0-9_-]{11})(?:\?[^\s]*)?)},
      %r{((?:https?://)?(?:www\.)?youtube\.com/embed/([a-zA-Z0-9_-]{11})(?:\?[^\s]*)?)},
      %r{((?:https?://)?(?:www\.)?youtube\.com/v/([a-zA-Z0-9_-]{11})(?:\?[^\s]*)?)}
    ]
    
    urls = []
    patterns.each do |pattern|
      body.scan(pattern) do |url, video_id|
        # Make sure URL has protocol
        full_url = url.start_with?('http') ? url : "https://#{url}"
        urls << { id: video_id, url: full_url }
      end
    end
    
    urls.uniq { |u| u[:id] }
  end
  
  def has_youtube_links?
    youtube_urls.any?
  end
  
  def web_urls
    return [] unless body.present?
    
    # URL pattern - matches http(s) URLs
    url_pattern = %r{(https?://[^\s<]+)}
    
    urls = []
    body.scan(url_pattern) do |url|
      full_url = url[0]
      # Skip YouTube URLs as they're handled separately
      next if full_url.match?(/(?:youtube\.com|youtu\.be)/)
      
      urls << full_url
    end
    
    urls.uniq
  end
  
  def has_web_links?
    web_urls.any?
  end
  
  def link_previews
    return [] unless has_web_links?
    
    web_urls.map do |url|
      # Cache the preview data
      Rails.cache.fetch("link_preview:#{Digest::SHA256.hexdigest(url)}", expires_in: 24.hours) do
        LinkPreviewService.fetch(url)
      end
    end.compact
  end
  
  def has_attachments_or_note?
    attachments.attached? || note_id.present?
  end
  
  def has_attachments?
    attachments.attached?
  end
  
  def image_attachments
    attachments.select { |a| a.content_type.start_with?('image/') }
  end
  
  def video_attachments
    attachments.select { |a| a.content_type.start_with?('video/') }
  end
  
  def non_image_attachments
    attachments.reject { |a| a.content_type.start_with?('image/', 'video/') }
  end
  
  def is_shared?
    shared_from_message_id.present?
  end
  
  def share_to_channel(target_channel, sharing_user)
    # Create a new message in the target channel
    shared_message = target_channel.messages.build(
      body: body,
      user: user, # Original author
      shared_from_message_id: id,
      shared_from_channel_id: channel_id,
      shared_by_user_id: sharing_user.id
    )
    
    # Copy attachments by reference (not duplicating files)
    if attachments.attached?
      attachments.each do |attachment|
        shared_message.attachments.attach(attachment.blob)
      end
    end
    
    # Copy note reference if present
    shared_message.note_id = note_id if note_id.present?
    
    shared_message.save
    shared_message
  end
  
  def process_mentions
    return unless body.present?
    
    # Find all @username patterns in the message (supports Korean characters)
    mention_pattern = /@([가-힣a-zA-Z0-9_]+)/
    mentioned_usernames = body.scan(mention_pattern).flatten.uniq
    
    return if mentioned_usernames.empty?
    
    # Find users in the same channel by matching name (not just full_name)
    channel_users = channel.users.select do |user|
      user_name = user.name.downcase.gsub(/\s+/, '') # Remove spaces for matching
      mentioned_usernames.any? { |username| user_name.include?(username.downcase) }
    end
    
    # Create mention records
    channel_users.each do |mentioned_user|
      message_mentions.find_or_create_by(user: mentioned_user)
    end
  end
  
  def body_with_mentions_html
    return ERB::Util.html_escape(body) unless body.present?
    
    # First escape the entire body for safety
    escaped_body = ERB::Util.html_escape(body)
    
    # Replace @username with highlighted spans (supports Korean characters)
    mentions_replaced = escaped_body.gsub(/@([가-힣a-zA-Z0-9_]+)/) do |match|
      username = $1
      # Find user by matching name (more flexible than exact full_name match)
      user = channel.users.find { |u| u.name.downcase.gsub(/\s+/, '').include?(username.downcase) }
      
      if user
        "<span class='mention' data-user-id='#{user.id}'>@#{ERB::Util.html_escape(username)}</span>"
      else
        match
      end
    end
    
    # Auto-link URLs
    url_pattern = %r{
      (                                           # Capture group for the entire URL
        (?:https?://|ftp://|www\.)                # Protocol or www
        (?:[a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+      # Domain and subdomains
        (?:\.[a-zA-Z]{2,})+                      # TLD
        (?::[0-9]{1,5})?                         # Optional port
        (?:/[^\s<>]*)?                            # Optional path
        (?:\?[^\s<>]*)?                           # Optional query string
        (?:\#[^\s<>]*)?                           # Optional fragment
      )
      |                                           # OR
      (                                           # Simple domain pattern
        (?<!\S)                                   # Not preceded by non-whitespace
        [a-zA-Z0-9\-]+                           # Domain
        (?:\.[a-zA-Z0-9\-]+)*                    # Subdomains
        \.[a-zA-Z]{2,}                           # TLD
        (?:/[^\s<>]*)?                            # Optional path
        (?=\s|$|[<>])                            # Followed by space, end, or tag
      )
    }xi
    
    with_links = mentions_replaced.gsub(url_pattern) do |url|
      # Skip if it's already part of a link or mention
      next url if url.include?('data-user-id')
      
      # Add protocol if missing
      href = if url.start_with?('http://', 'https://', 'ftp://')
        url
      else
        "https://#{url.sub(/^www\./, '')}"
      end
      
      # Clean display URL (remove protocol for display)
      display_url = url.sub(/^https?:\/\/(www\.)?/, '')
      display_url = display_url.length > 50 ? "#{display_url[0..47]}..." : display_url
      
      "<a href='#{href}' target='_blank' rel='noopener noreferrer' class='text-blue-600 hover:text-blue-800 underline break-all'>#{ERB::Util.html_escape(display_url)}</a>"
    end
    
    # Convert newlines to <br> tags for proper display
    with_links.gsub("\n", "<br>").html_safe
  end
  
  private
  
  def validate_attachments
    return unless attachments.attached?
    
    attachments.each do |attachment|
      # Check file size
      if attachment.blob.content_type.start_with?('video/')
        if attachment.blob.byte_size > MAX_VIDEO_SIZE
          errors.add(:attachments, "동영상 파일 크기는 50MB를 초과할 수 없습니다: #{attachment.filename}")
        end
      elsif attachment.blob.byte_size > MAX_FILE_SIZE
        errors.add(:attachments, "파일 크기는 25MB를 초과할 수 없습니다: #{attachment.filename}")
      end
      
      # Check file type
      unless ALLOWED_FILE_TYPES.include?(attachment.blob.content_type)
        errors.add(:attachments, "허용되지 않는 파일 형식입니다: #{attachment.filename}")
      end
    end
  end
  
  def validate_note_workspace
    return unless note_id.present?
    
    # Ensure the note belongs to the same workspace as the channel
    if note && note.workspace_id != channel.workspace_id
      errors.add(:note, "다른 워크스페이스의 노트는 첨부할 수 없습니다")
    end
  end
  
  def broadcast_remove
    # Broadcast to channel for real-time removal
    ActionCable.server.broadcast(
      "channel_#{channel_id}_reactions",
      {
        action: "remove",
        message_id: id,
        html: "" # Empty HTML to remove the message
      }
    )
  end
end
