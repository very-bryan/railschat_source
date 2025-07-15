class Notification < ApplicationRecord
  belongs_to :user, counter_cache: :notifications_count
  belongs_to :related, polymorphic: true, optional: true
  
  validates :title, presence: true
  validates :notification_type, presence: true
  validates :priority, inclusion: { in: 1..5 }
  
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_priority, -> { order(priority: :desc, created_at: :desc) }
  
  TYPES = %w[
    note_assigned
    note_due_soon
    note_overdue
    note_completed
    note_commented
    message_received
    message_reply
    message_mention
    channel_invited
    system_announcement
    task_reminder
  ].freeze
  
  validates :notification_type, inclusion: { in: TYPES }
  
  after_create :increment_unread_count
  after_update :update_unread_count, if: :saved_change_to_read?
  
  def mark_as_read!
    update!(read: true)
  end
  
  def mark_as_unread!
    update!(read: false)
  end
  
  def priority_label
    case priority
    when 5 then '긴급'
    when 4 then '높음'
    when 3 then '보통'
    when 2 then '낮음'
    when 1 then '정보'
    else '알 수 없음'
    end
  end
  
  def type_icon
    case notification_type
    when 'note_assigned' then '📝'
    when 'note_due_soon' then '⏰'
    when 'note_overdue' then '🚨'
    when 'note_completed' then '✅'
    when 'note_commented' then '💬'
    when 'message_received' then '💬'
    when 'message_reply' then '↩️'
    when 'message_mention' then '@'
    when 'channel_invited' then '🏷️'
    when 'system_announcement' then '📢'
    when 'task_reminder' then '🔔'
    else '📋'
    end
  end
  
  def type_color
    case notification_type
    when 'note_assigned' then 'blue'
    when 'note_due_soon' then 'yellow'
    when 'note_overdue' then 'red'
    when 'note_completed' then 'green'
    when 'note_commented' then 'indigo'
    when 'message_received' then 'purple'
    when 'message_reply' then 'pink'
    when 'message_mention' then 'purple'
    when 'channel_invited' then 'indigo'
    when 'system_announcement' then 'gray'
    when 'task_reminder' then 'orange'
    else 'gray'
    end
  end
  
  private
  
  def increment_unread_count
    return if read?
    user.increment!(:unread_notifications_count)
  end
  
  def update_unread_count
    if read?
      # 음수가 되지 않도록 체크
      if user.unread_notifications_count > 0
        user.decrement!(:unread_notifications_count)
      end
    else
      user.increment!(:unread_notifications_count)
    end
  end
end
