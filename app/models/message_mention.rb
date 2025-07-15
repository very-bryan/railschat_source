class MessageMention < ApplicationRecord
  belongs_to :message
  belongs_to :user
  
  after_create :create_mention_notification
  
  private
  
  def create_mention_notification
    # Skip if mentioning yourself
    return if message.user_id == user_id
    
    NotificationService.create_notification(
      user: user,
      notification_type: 'message_mention',
      title: "#{message.user.name}님이 회원님을 멘션했습니다",
      body: message.body.truncate(100),
      action_url: Rails.application.routes.url_helpers.chat_channel_path(message.channel),
      priority: 4,
      related: message
    )
  end
end