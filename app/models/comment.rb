class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  
  validates :content, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  
  has_many_attached :attachments
  
  after_create :send_notification
  
  private
  
  def send_notification
    return unless commentable.is_a?(Note)
    
    # 노트 작성자에게 알림
    if commentable.user != user
      NotificationService.create_notification(
        user: commentable.user,
        title: "#{user.name}님이 댓글을 남겼습니다",
        body: content.truncate(100),
        notification_type: 'note_commented',
        priority: 3,
        related: self,
        action_url: Rails.application.routes.url_helpers.note_path(commentable)
      )
    end
    
    # 다른 댓글 작성자들에게도 알림
    commentable.comments.where.not(user: [user, commentable.user]).select(:user_id).distinct.each do |comment|
      NotificationService.create_notification(
        user: comment.user,
        title: "#{user.name}님이 댓글을 남겼습니다",
        body: content.truncate(100),
        notification_type: 'note_commented',
        priority: 3,
        related: self,
        action_url: Rails.application.routes.url_helpers.note_path(commentable)
      )
    end
  end
end
