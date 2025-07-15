namespace :mention do
  desc "Create test mention messages for notification testing"
  task test_notifications: :environment do
    # Bryan 확인
    bryan = User.find_by(email: 'thenaeun1@gmail.com')
    puts "Bryan: #{bryan.name} (ID: #{bryan.id})"
    
    # 멘션테스트 채널 확인
    channel = Channel.find_by(name: '멘션테스트')
    unless channel
      puts 'Creating 멘션테스트 channel...'
      channel = bryan.current_workspace.channels.create!(
        name: '멘션테스트',
        description: '멘션 알림 테스트',
        is_private: false
      )
    end
    
    # Bryan이 채널에 있는지 확인
    unless channel.users.include?(bryan)
      channel.channel_members.create!(user: bryan, role: 'admin')
    end
    
    # 다른 사용자가 없으면 생성
    if channel.users.count < 2
      puts "Creating test users..."
      ['김테스터', '이테스터', '박테스터'].each_with_index do |name, i|
        user = User.find_or_create_by(email: "tester#{i+1}@test.com") do |u|
          u.password = 'password123'
          u.first_name = name
          u.last_name = ''
        end
        bryan.current_workspace.workspace_members.find_or_create_by(user: user, role: 'member')
        channel.channel_members.find_or_create_by(user: user, role: 'member')
      end
    end
    
    other_users = channel.users.where.not(id: bryan.id)
    puts "\nChannel members: #{channel.users.map(&:name).join(', ')}"
    
    # 새로운 멘션 메시지 생성
    puts "\nCreating new mention messages..."
    messages = [
      { user: other_users[0], body: '@Bryan 긴급! 이거 확인 부탁드려요 🚨' },
      { user: other_users[1], body: '회의 일정 변경됐습니다 @Bryan 확인해주세요' },
      { user: other_users[0], body: '@Bryan PR 리뷰 부탁드립니다 🙏' },
      { user: other_users[1], body: '디자인 수정사항 있어요 @Bryan' },
      { user: other_users[2] || other_users[0], body: '@Bryan 점심 같이 드실래요? 😊' },
      { user: other_users[0], body: '좋은 아이디어네요 @Bryan 👍 덕분에 해결했어요!' },
      { user: other_users[1], body: '@Bryan 파일 공유드립니다. 검토 후 피드백 부탁드려요' },
      { user: other_users[2] || other_users[1], body: '프로젝트 진행상황 업데이트했습니다 @Bryan' }
    ]
    
    messages.each_with_index do |msg_data, i|
      if msg_data[:user]
        message = channel.messages.create!(
          user: msg_data[:user],
          body: msg_data[:body],
          created_at: (messages.length - i).minutes.ago
        )
        puts "Created: #{msg_data[:body]}"
      end
    end
    
    # 알림 확인
    sleep 1
    notifications = bryan.notifications.where(notification_type: 'message_mention').order(created_at: :desc).limit(10)
    puts "\n최근 멘션 알림 (#{notifications.count}개):"
    notifications.each do |n|
      puts "- #{n.title}"
      puts "  내용: #{n.body}"
      puts "  읽음: #{n.read ? '예' : '아니오'}"
      puts "  생성: #{n.created_at.strftime('%H:%M')}"
      puts ""
    end
    
    unread_count = bryan.notifications.unread.count
    mention_unread = bryan.notifications.unread.where(notification_type: 'message_mention').count
    puts "\n📊 알림 통계:"
    puts "- 총 읽지 않은 알림: #{unread_count}개"
    puts "- 읽지 않은 멘션 알림: #{mention_unread}개"
    puts "\n✅ 알림 페이지에서 확인해보세요!"
  end
end