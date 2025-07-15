class NotificationService
  def self.create_notification(user:, title:, body: nil, notification_type:, priority: 3, related: nil, action_url: nil)
    return unless user.present?
    
    # Check user's notification preferences
    return unless should_send_notification?(user, notification_type)
    
    notification = user.notifications.create!(
      title: title,
      body: body,
      notification_type: notification_type,
      priority: priority,
      related: related,
      action_url: action_url,
      read: false
    )
    
    # Here we could add email notifications if enabled
    # TODO: Implement NotificationMailer with Resend
    # if user.email_notifications && user.push_notifications
    #   NotificationMailer.new_notification(notification).deliver_later
    # end
    
    # Broadcast real-time notification if using ActionCable
    # broadcast_notification(notification)
    
    notification
  end
  
  def self.should_send_notification?(user, notification_type)
    # For now, use the general email_notifications setting
    # Later we can add more granular settings if needed
    user.email_notifications
  end
  
  # Notification creation helpers
  def self.note_assigned(note, assignee)
    create_notification(
      user: assignee,
      title: "새 노트가 할당되었습니다",
      body: "#{note.content.truncate(100)}",
      notification_type: 'note_assigned',
      priority: 4,
      related: note,
      action_url: Rails.application.routes.url_helpers.note_path(note)
    )
  end
  
  def self.message_received(message, recipient)
    create_notification(
      user: recipient,
      title: "#{message.user.name || message.user.email}님이 메시지를 보냈습니다",
      body: message.content.truncate(100),
      notification_type: 'message_received',
      priority: 3,
      related: message,
      action_url: Rails.application.routes.url_helpers.workspace_path(message.workspace)
    )
  end
  
  def self.system_announcement(title, body, users = User.all)
    users.find_each do |user|
      create_notification(
        user: user,
        title: title,
        body: body,
        notification_type: 'system_announcement',
        priority: 2
      )
    end
  end
end