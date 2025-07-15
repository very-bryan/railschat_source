namespace :sample do
  desc "Generate sample chat messages and notifications for Apple workspace"
  task messages: :environment do
    # Find Apple workspace (case-insensitive)
    workspace = Workspace.where("LOWER(name) = ?", "apple").first
    unless workspace
      puts "Apple workspace not found!"
      exit
    end
    
    puts "Found Apple workspace with #{workspace.users.count} users"
    
    # Sample Korean names for creating additional users if needed
    korean_names = [
      "김민수", "이서연", "박지훈", "최은지", "정태우",
      "강다은", "조현우", "윤서진", "장민호", "임수진",
      "한지원", "서유진", "신동현", "오지영", "권민재"
    ]
    
    # Ensure we have enough users
    users = workspace.users.to_a
    while users.size < 8
      name = korean_names[users.size]
      email = "#{name.gsub(/\s/, '').downcase}@apple.com"
      user = User.find_or_create_by!(email: email) do |u|
        # Split Korean name - last character is usually first name
        if name.length >= 2
          u.last_name = name[0]
          u.first_name = name[1..-1]
        else
          u.first_name = name
        end
        u.password = "password123"
        u.password_confirmation = "password123"
      end
      workspace.users << user unless workspace.users.include?(user)
      users << user
      puts "Created user: #{name} (#{email})"
    end
    
    # Find or create channels
    channels = []
    
    # General channel
    general = workspace.channels.find_or_create_by!(name: "general") do |c|
      c.description = "전체 공지 및 일반 대화"
      c.is_private = false
    end
    channels << general
    
    # Development team channel
    dev_channel = workspace.channels.find_or_create_by!(name: "개발팀") do |c|
      c.description = "개발팀 업무 협의"
      c.is_private = false
    end
    channels << dev_channel
    
    # Marketing team channel
    marketing_channel = workspace.channels.find_or_create_by!(name: "마케팅팀") do |c|
      c.description = "마케팅 전략 및 캠페인 논의"
      c.is_private = false
    end
    channels << marketing_channel
    
    # Random chat channel
    random_channel = workspace.channels.find_or_create_by!(name: "잡담방") do |c|
      c.description = "자유로운 대화와 친목"
      c.is_private = false
    end
    channels << random_channel
    
    # Private project channel
    project_channel = workspace.channels.find_or_create_by!(name: "신제품-프로젝트") do |c|
      c.description = "신제품 개발 프로젝트 (기밀)"
      c.is_private = true
    end
    channels << project_channel
    
    # Add users to channels
    channels.each do |channel|
      users.sample(rand(5..8)).each do |user|
        channel.channel_members.find_or_create_by!(user: user) do |member|
          member.role = (rand < 0.2) ? 'admin' : 'member'
        end
      end
    end
    
    puts "Created/found #{channels.size} channels"
    
    # Sample conversation patterns
    conversations = {
      general: [
        { user_index: 0, message: "안녕하세요 여러분! 오늘 회의는 오후 3시에 진행됩니다." },
        { user_index: 1, message: "네, 알겠습니다. 회의실은 어디인가요?" },
        { user_index: 0, message: "3층 대회의실입니다. @이서연 님도 참석하시죠?" },
        { user_index: 2, message: "네, 참석하겠습니다!" },
        { user_index: 3, message: "회의 자료는 언제까지 준비하면 될까요?" },
        { user_index: 0, message: "회의 30분 전까지만 공유해주시면 됩니다." },
        { user_index: 4, message: "프로젝트 진행 상황도 공유 부탁드립니다 👍" }
      ],
      development: [
        { user_index: 2, message: "API 개발 완료했습니다. 테스트 부탁드려요." },
        { user_index: 5, message: "수고하셨습니다! 지금 바로 테스트해보겠습니다." },
        { user_index: 2, message: "감사합니다. 문서는 Wiki에 업데이트했어요." },
        { user_index: 6, message: "코드 리뷰 완료했습니다. LGTM 👍" },
        { user_index: 2, message: "감사합니다! 머지하겠습니다." },
        { user_index: 5, message: "버그 하나 발견했는데요, @박지훈 님 확인 부탁드려요." },
        { user_index: 2, message: "어떤 버그인가요? 자세히 알려주세요." },
        { user_index: 5, message: "로그인 시 에러가 발생합니다. 스크린샷 첨부할게요." }
      ],
      marketing: [
        { user_index: 3, message: "이번 캠페인 반응이 정말 좋네요! 🎉" },
        { user_index: 7, message: "맞아요! 전환율이 15% 상승했습니다." },
        { user_index: 3, message: "다음 캠페인도 기대가 됩니다." },
        { user_index: 1, message: "SNS 광고 예산을 좀 더 늘려보는 건 어떨까요?" },
        { user_index: 7, message: "좋은 생각입니다. @최은지 님 의견은 어떠신가요?" },
        { user_index: 3, message: "동의합니다. 특히 인스타그램 쪽을 강화하면 좋을 것 같아요." }
      ],
      random: [
        { user_index: 4, message: "오늘 날씨 정말 좋네요! ☀️" },
        { user_index: 6, message: "그러게요! 점심은 밖에서 먹을까요?" },
        { user_index: 1, message: "좋아요! 회사 근처 새로 생긴 카페 어때요?" },
        { user_index: 4, message: "오 좋은데요? 거기 샌드위치가 맛있다고 들었어요." },
        { user_index: 7, message: "저도 같이 가도 될까요? 😊" },
        { user_index: 1, message: "당연하죠! 다같이 가요!" },
        { user_index: 2, message: "저는 아쉽게도 회의가 있네요 ㅠㅠ" },
        { user_index: 4, message: "다음에 꼭 같이 가요!" }
      ],
      project: [
        { user_index: 0, message: "신제품 디자인 시안 공유드립니다. 🎨" },
        { user_index: 5, message: "와, 정말 세련된 디자인이네요!" },
        { user_index: 3, message: "색상이 우리 브랜드와 잘 어울리는 것 같아요." },
        { user_index: 0, message: "감사합니다. @정태우 님 기술적으로 구현 가능한가요?" },
        { user_index: 4, message: "네, 충분히 가능합니다. 다만 일정이 좀 빠듯할 것 같네요." },
        { user_index: 0, message: "일정 조율해서 진행하겠습니다." }
      ]
    }
    
    # Generate messages with timestamps spread across recent days
    message_count = 0
    
    channels.each_with_index do |channel, channel_index|
      # Determine which conversation to use
      conv_key = case channel.name
      when "general" then :general
      when "개발팀" then :development
      when "마케팅팀" then :marketing
      when "잡담방" then :random
      when "신제품-프로젝트" then :project
      else :general
      end
      
      conversation = conversations[conv_key]
      channel_users = channel.users.to_a
      
      # Generate main messages
      base_time = rand(5.days.ago..1.day.ago)
      thread_roots = []
      
      conversation.each_with_index do |msg_data, index|
        user = channel_users[msg_data[:user_index] % channel_users.size]
        timestamp = base_time + (index * rand(5..30).minutes)
        
        message = channel.messages.create!(
          user: user,
          body: msg_data[:message],
          created_at: timestamp,
          updated_at: timestamp
        )
        
        # Save some messages as thread roots for replies
        thread_roots << message if rand < 0.3
        
        # Add reactions randomly
        if rand < 0.4
          emoji_options = ["👍", "❤️", "😊", "🎉", "💯", "🔥", "👏"]
          rand(1..3).times do
            reactor = channel_users.sample
            emoji = emoji_options.sample
            # Avoid duplicate reactions from same user
            unless message.reactions.exists?(user: reactor, emoji: emoji)
              message.reactions.create!(
                user: reactor,
                emoji: emoji
              )
            end
          end
        end
        
        # Pin important messages
        if rand < 0.1
          message.pin!
        end
        
        message_count += 1
      end
      
      # Generate thread replies
      thread_roots.each do |root_message|
        reply_count = rand(2..5)
        reply_count.times do |i|
          replier = channel_users.sample
          timestamp = root_message.created_at + ((i + 1) * rand(10..60).minutes)
          
          reply_messages = [
            "좋은 의견이네요!",
            "동의합니다.",
            "추가로 이런 것도 고려해보면 어떨까요?",
            "제 생각은 조금 다른데요...",
            "자세한 설명 감사합니다!",
            "이 부분은 다시 논의가 필요할 것 같아요.",
            "좋습니다! 진행하시죠."
          ]
          
          reply = channel.messages.create!(
            user: replier,
            body: reply_messages.sample,
            thread_root: root_message,
            parent_message: root_message,
            created_at: timestamp,
            updated_at: timestamp
          )
          
          message_count += 1
        end
      end
    end
    
    puts "Created #{message_count} messages"
    
    # Generate notifications
    notification_count = 0
    
    users.each do |user|
      # Message mention notifications (already created by mentions)
      
      # Note assignment notifications
      rand(1..3).times do
        notification = user.notifications.create!(
          notification_type: 'note_assigned',
          title: "새로운 작업이 할당되었습니다",
          body: "#{['프로젝트 기획서 작성', 'API 문서 업데이트', '디자인 시안 검토', '회의록 작성'].sample} 작업이 할당되었습니다.",
          priority: 3,
          created_at: rand(7.days.ago..1.hour.ago),
          read: rand < 0.6
        )
        notification_count += 1
      end
      
      # Note due soon notifications
      rand(0..2).times do
        notification = user.notifications.create!(
          notification_type: 'note_due_soon',
          title: "작업 마감일이 임박했습니다",
          body: "#{['보고서 제출', '코드 리뷰', '프레젠테이션 준비'].sample} 작업이 곧 마감됩니다.",
          priority: 4,
          created_at: rand(3.days.ago..1.hour.ago),
          read: rand < 0.4
        )
        notification_count += 1
      end
      
      # Channel invitation notifications
      rand(0..1).times do
        notification = user.notifications.create!(
          notification_type: 'channel_invited',
          title: "새로운 채널에 초대되었습니다",
          body: "#{['프로젝트-알파', '주간회의', 'QA팀'].sample} 채널에 초대되었습니다.",
          priority: 2,
          created_at: rand(5.days.ago..1.day.ago),
          read: rand < 0.8
        )
        notification_count += 1
      end
      
      # System announcements
      if rand < 0.3
        notification = user.notifications.create!(
          notification_type: 'system_announcement',
          title: "시스템 공지사항",
          body: ["정기 점검 안내: 금요일 오후 10시", "새로운 기능이 추가되었습니다", "보안 업데이트 완료"].sample,
          priority: 1,
          created_at: rand(7.days.ago..1.day.ago),
          read: rand < 0.9
        )
        notification_count += 1
      end
      
      # Task reminders
      rand(0..2).times do
        notification = user.notifications.create!(
          notification_type: 'task_reminder',
          title: "작업 리마인더",
          body: "#{['일일 스탠드업 미팅', '주간 보고서 작성', '코드 배포 준비'].sample}을(를) 잊지 마세요!",
          priority: 2,
          created_at: rand(2.days.ago..2.hours.ago),
          read: rand < 0.5
        )
        notification_count += 1
      end
    end
    
    puts "Created #{notification_count} notifications"
    
    # Create some notes for note-related notifications
    categories = workspace.categories.to_a
    statuses = workspace.statuses.to_a
    
    if categories.empty?
      categories = [
        workspace.categories.create!(name: "개발", color: "#3B82F6"),
        workspace.categories.create!(name: "디자인", color: "#8B5CF6"),
        workspace.categories.create!(name: "마케팅", color: "#10B981")
      ]
    end
    
    if statuses.empty?
      statuses = [
        workspace.statuses.create!(name: "할 일", color: "#6B7280"),
        workspace.statuses.create!(name: "진행 중", color: "#3B82F6"),
        workspace.statuses.create!(name: "완료", color: "#10B981")
      ]
    end
    
    note_count = 0
    10.times do
      note = workspace.notes.create!(
        title: ["프로젝트 기획서", "API 설계 문서", "마케팅 전략", "UI/UX 개선안", "버그 리포트"].sample,
        body: "이것은 샘플 노트 내용입니다. 실제 작업 내용이 여기에 들어갑니다.",
        user: users.sample,
        category: categories.sample,
        status: statuses.sample,
        created_at: rand(14.days.ago..1.day.ago)
      )
      note_count += 1
    end
    
    puts "Created #{note_count} notes"
    puts "\nSample data generation completed!"
    puts "Summary:"
    puts "- Users: #{users.size}"
    puts "- Channels: #{channels.size}"
    puts "- Messages: #{message_count}"
    puts "- Notifications: #{notification_count}"
    puts "- Notes: #{note_count}"
  end
end