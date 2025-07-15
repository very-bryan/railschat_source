namespace :dummy do
  desc "Apple 워크스페이스의 채널에 10개의 더미 메시지 생성"
  task messages: :environment do
    # Apple 워크스페이스 찾기
    workspace = Workspace.find_by(name: 'apple')
    
    unless workspace
      puts "Error: apple 워크스페이스를 찾을 수 없습니다."
      exit
    end
    
    # 현재 사용자 찾기 (oddys@naver.com)
    current_user = workspace.users.find_by(email: 'oddys@naver.com')
    
    unless current_user
      puts "Error: apple 워크스페이스에서 oddys@naver.com 사용자를 찾을 수 없습니다."
      exit
    end
    
    # Apple 워크스페이스의 모든 채널 가져오기
    channels = workspace.channels
    
    if channels.empty?
      puts "Error: 채널을 찾을 수 없습니다."
      exit
    end
    
    puts "#{channels.count}개 채널에 더미 메시지를 생성합니다..."
    
    # 각 채널별로 메시지 생성
    channels.each do |channel|
      puts "\n채널: #{channel.name}"
      
      # 채널의 다른 멤버들 가져오기
      other_members = channel.users.where.not(id: current_user.id)
      
      if other_members.empty?
        puts "  - 다른 멤버가 없어 스킵합니다."
        next
      end
      
      # 10개의 메시지 생성
      10.times do |i|
        # 랜덤하게 멤버 선택
        sender = other_members.sample
        
        # 다양한 메시지 내용 생성
        messages = [
          "안녕하세요 @#{current_user.name}님! 오늘 회의 준비는 잘 되셨나요?",
          "@#{current_user.name} 프로젝트 진행 상황 공유 부탁드립니다.",
          "좋은 아이디어네요! @#{current_user.name}님 의견이 궁금합니다.",
          "https://github.com/rails/rails 이 링크 확인해보세요 @#{current_user.name}",
          "@#{current_user.name}님, 내일 일정 확인 부탁드려요!",
          "수고하셨습니다 @#{current_user.name}님! 👍",
          "@#{current_user.name} 문서 검토 완료했습니다. 피드백 있으시면 알려주세요.",
          "www.example.com/docs 여기에 자료 올려놨어요 @#{current_user.name}",
          "@#{current_user.name}님 점심 메뉴 추천해주세요 😊",
          "회의록 공유합니다: https://docs.google.com/document/d/123 @#{current_user.name}"
        ]
        
        message_body = messages[i % messages.length]
        
        # 메시지 생성
        message = channel.messages.create!(
          body: message_body,
          user: sender,
          created_at: (10 - i).minutes.ago
        )
        
        puts "  - #{sender.name}: #{message_body[0..50]}..."
        
        # 50% 확률로 이모지 반응 추가
        if rand(2) == 1
          emoji = ['👍', '❤️', '😊', '🎉', '💯'].sample
          message.reactions.create!(
            user: other_members.sample,
            emoji: emoji
          )
        end
      end
    end
    
    puts "\n✅ 더미 메시지 생성 완료!"
    puts "총 #{channels.count * 10}개의 메시지가 생성되었습니다."
    puts "\n멘션된 사용자: #{current_user.name} (#{current_user.email})"
    puts "알림이 자동으로 생성될 것입니다."
  end
end