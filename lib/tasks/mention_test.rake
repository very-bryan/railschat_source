namespace :mention do
  desc "Create mention test messages for Bryan"
  task test: :environment do
    # Find Bryan (current user)
    bryan = User.find_by(email: 'thenaeun1@gmail.com')
    unless bryan
      puts "Bryan user not found!"
      exit
    end
    
    # Get Bryan's current workspace
    workspace = bryan.current_workspace
    unless workspace
      puts "No current workspace found for Bryan!"
      exit
    end
    
    # Find or create a test channel
    channel = workspace.channels.find_or_create_by(name: '멘션테스트') do |c|
      c.description = '멘션 기능 테스트용 채널'
      c.is_private = false
    end
    
    # Make sure Bryan is in the channel
    channel.channel_members.find_or_create_by(user: bryan, role: 'admin')
    
    # Find other users in the workspace
    other_users = workspace.users.where.not(id: bryan.id)
    
    if other_users.empty?
      puts "No other users found in workspace. Creating test users..."
      
      # Create test users
      test_users = [
        { email: 'jane@test.com', first_name: 'Jane', last_name: 'Designer' },
        { email: 'jimin@test.com', first_name: '지민', last_name: '김' },
        { email: 'seoyeon@test.com', first_name: '서연', last_name: '이' },
        { email: 'john@test.com', first_name: 'John', last_name: 'Developer' }
      ]
      
      test_users.each do |user_data|
        user = User.find_or_create_by(email: user_data[:email]) do |u|
          u.password = 'password123'
          u.first_name = user_data[:first_name]
          u.last_name = user_data[:last_name]
        end
        
        # Add to workspace
        workspace.workspace_members.find_or_create_by(user: user, role: 'member')
        
        # Add to channel
        channel.channel_members.find_or_create_by(user: user, role: 'member')
      end
      
      other_users = workspace.users.where.not(id: bryan.id).reload
    else
      # Make sure all existing users are in the channel
      other_users.each do |user|
        channel.channel_members.find_or_create_by(user: user, role: 'member')
      end
    end
    
    puts "Creating mention test messages..."
    
    # Create messages mentioning Bryan
    mention_messages = [
      { user: other_users[0], body: "@bryan 이거 확인해주실 수 있나요?" },
      { user: other_users[1], body: "프로젝트 진행 상황 공유드립니다 @bryan" },
      { user: other_users[2], body: "@bryan님 회의 시간 변경 가능하신가요?" },
      { user: other_users[0], body: "좋은 아이디어네요 @bryan! 👍" },
      { user: other_users[3] || other_users[0], body: "@bryan 파일 전달드립니다. 검토 부탁드려요." },
      { user: other_users[1], body: "오늘 점심 메뉴 추천해주세요 @bryan ㅎㅎ" },
      { user: other_users[2], body: "@bryan 코드 리뷰 완료했습니다!" },
      { user: other_users[0], body: "감사합니다 @bryan 님! 덕분에 해결했어요 🎉" }
    ]
    
    mention_messages.each_with_index do |msg_data, index|
      if msg_data[:user]
        message = channel.messages.create!(
          user: msg_data[:user],
          body: msg_data[:body],
          created_at: (8 - index).minutes.ago
        )
        
        puts "Created message: #{msg_data[:body]} (from #{msg_data[:user].name})"
      end
    end
    
    # Also create some messages between other users with mentions
    other_mentions = [
      { user: other_users[0], body: "@Jane 이거 봐주세요!" },
      { user: other_users[1], body: "@지민 님 수고하셨습니다" },
      { user: other_users[2], body: "좋은 하루 되세요 @서연" }
    ]
    
    other_mentions.each do |msg_data|
      if msg_data[:user]
        channel.messages.create!(
          user: msg_data[:user],
          body: msg_data[:body],
          created_at: rand(1..5).minutes.ago
        )
      end
    end
    
    puts "\n✅ Mention test messages created successfully!"
    puts "📍 Channel: ##{channel.name}"
    puts "👥 Total users in channel: #{channel.users.count}"
    puts "💬 Total messages created: #{mention_messages.length + other_mentions.length}"
    puts "\n🔔 Check your notifications for mentions!"
  end
end