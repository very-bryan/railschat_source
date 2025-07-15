namespace :notifications do
  desc "Create sample notifications for testing"
  task create_samples: :environment do
    user = User.first
    
    if user.nil?
      puts "No users found. Please create a user first."
      exit
    end
    
    # Create various types of notifications
    notifications = [
      {
        title: "시스템 업데이트 안내",
        body: "새로운 기능이 추가되었습니다. 노트에 파일을 첨부할 수 있게 되었습니다.",
        notification_type: "system_announcement",
        priority: 2
      },
      {
        title: "새 노트가 할당되었습니다",
        body: "프로젝트 계획서 작성 업무가 할당되었습니다.",
        notification_type: "note_assigned",
        priority: 4
      },
      {
        title: "메시지를 받았습니다",
        body: "김철수님이 '안녕하세요, 회의 시간 확인 부탁드립니다.'라고 메시지를 보냈습니다.",
        notification_type: "message_received",
        priority: 3
      },
      {
        title: "마감일이 임박한 노트가 있습니다",
        body: "보고서 제출 마감일이 2일 남았습니다.",
        notification_type: "note_due_soon",
        priority: 4
      },
      {
        title: "노트가 완료되었습니다",
        body: "디자인 검토 업무가 완료 처리되었습니다.",
        notification_type: "note_completed",
        priority: 2,
        read: true
      }
    ]
    
    notifications.each do |attrs|
      notification = user.notifications.create!(attrs)
      puts "Created notification: #{notification.title}"
    end
    
    puts "\nSuccessfully created #{notifications.count} sample notifications for #{user.email}"
    puts "Unread notifications: #{user.notifications.unread.count}"
  end
  
  desc "Clear all notifications"
  task clear_all: :environment do
    count = Notification.destroy_all.count
    puts "Deleted #{count} notifications"
  end
end