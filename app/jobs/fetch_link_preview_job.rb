class FetchLinkPreviewJob < ApplicationJob
  queue_as :default
  
  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message
    
    # Fetch previews for all web URLs in the message
    message.web_urls.each do |url|
      cache_key = "link_preview:#{Digest::SHA256.hexdigest(url)}"
      
      # Skip if already cached
      next if Rails.cache.exist?(cache_key)
      
      # Fetch and cache the preview
      preview = LinkPreviewService.fetch(url)
      Rails.cache.write(cache_key, preview, expires_in: 24.hours) if preview
    end
    
    # Broadcast update to refresh the message with previews
    if message.has_web_links?
      ActionCable.server.broadcast(
        "channel_#{message.channel_id}_reactions",
        {
          message_id: message.id,
          html: ApplicationController.render(
            partial: 'messages/message',
            locals: { message: message }
          )
        }
      )
    end
  end
end