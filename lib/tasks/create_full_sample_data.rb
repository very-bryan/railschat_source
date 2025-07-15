# Script to create full sample data for AVA workspace
workspace = Workspace.find_by(name: 'AVA')

if workspace
  puts "Found workspace: #{workspace.name}"
  
  # Delete existing sample data
  Note.where(workspace: workspace, is_sample: true).destroy_all
  Message.joins(:channel).where(channels: { workspace: workspace }, is_sample: true).destroy_all
  
  # Delete sample users
  sample_emails = ["sample_kim@example.com", "sample_lee@example.com", 
                   "sample_kim_#{workspace.id}@example.com", "sample_lee_#{workspace.id}@example.com"]
  User.where(email: sample_emails).destroy_all
  
  puts "Deleted existing sample data"
  
  # Get the main user
  user = workspace.users.first
  
  if user
    # Create sample users
    sample_user1 = User.create!(
      email: "sample_kim_#{workspace.id}@example.com",
      password: SecureRandom.hex(10),
      first_name: "지민",
      last_name: "김",
      current_workspace: workspace
    )
    
    sample_user2 = User.create!(
      email: "sample_lee_#{workspace.id}@example.com", 
      password: SecureRandom.hex(10),
      first_name: "서연",
      last_name: "이",
      current_workspace: workspace
    )
    
    # Add sample users to workspace
    WorkspaceMember.create!(workspace: workspace, user: sample_user1, role: 'member')
    WorkspaceMember.create!(workspace: workspace, user: sample_user2, role: 'member')
    
    # Get channels
    general_channel = workspace.channels.find_by(name: 'general')
    random_channel = workspace.channels.find_by(name: 'random')
    
    if general_channel && random_channel
      # Add sample users to channels
      ChannelMember.find_or_create_by!(channel: general_channel, user: sample_user1) do |member|
        member.role = 'member'
      end
      ChannelMember.find_or_create_by!(channel: random_channel, user: sample_user1) do |member|
        member.role = 'member'
      end
      ChannelMember.find_or_create_by!(channel: general_channel, user: sample_user2) do |member|
        member.role = 'member'
      end
      ChannelMember.find_or_create_by!(channel: random_channel, user: sample_user2) do |member|
        member.role = 'member'
      end
      
      # Create sample messages with timestamps
      Message.create!(
        body: '안녕하세요! AVA 워크스페이스에 오신 것을 환영합니다 👋',
        user: sample_user1,
        channel: general_channel,
        is_sample: true,
        created_at: 2.hours.ago
      )
      
      Message.create!(
        body: 'AVA에서 함께 일하게 되어 기쁩니다. 잘 부탁드려요!',
        user: sample_user2,
        channel: general_channel,
        is_sample: true,
        created_at: 1.hour.ago + 50.minutes
      )
      
      Message.create!(
        body: '프로젝트 진행 상황 공유드립니다. API 문서 작성을 시작했습니다.',
        user: sample_user1,
        channel: general_channel,
        is_sample: true,
        created_at: 1.hour.ago
      )
      
      Message.create!(
        body: '좋습니다! 필요한 부분이 있으면 말씀해주세요.',
        user: user,
        channel: general_channel,
        is_sample: true,
        created_at: 50.minutes.ago
      )
      
      Message.create!(
        body: '성능 최적화 작업도 동시에 진행하고 있어요. 데이터베이스 쿼리부터 검토 중입니다.',
        user: sample_user2,
        channel: general_channel,
        is_sample: true,
        created_at: 45.minutes.ago
      )
      
      Message.create!(
        body: '오늘 날씨가 정말 좋네요! ☀️',
        user: sample_user1,
        channel: random_channel,
        is_sample: true,
        created_at: 40.minutes.ago
      )
      
      Message.create!(
        body: '맞아요! 점심시간에 산책하면 좋을 것 같아요 🚶‍♀️',
        user: sample_user2,
        channel: random_channel,
        is_sample: true,
        created_at: 35.minutes.ago
      )
      
      Message.create!(
        body: '커피 한잔 하실 분? ☕',
        user: sample_user1,
        channel: random_channel,
        is_sample: true,
        created_at: 30.minutes.ago
      )
      
      Message.create!(
        body: '저요! 5분 후에 1층에서 만나요 😊',
        user: sample_user2,
        channel: random_channel,
        is_sample: true,
        created_at: 28.minutes.ago
      )
      
      puts "Created sample messages"
    end
    
    # Get categories and statuses
    work_category = workspace.categories.find_by(name: '업무')
    personal_category = workspace.categories.find_by(name: '개인')
    idea_category = workspace.categories.find_by(name: '아이디어')
    
    backlog_status = workspace.statuses.find_by(name: 'Backlog')
    todo_status = workspace.statuses.find_by(name: 'To Do')
    in_progress_status = workspace.statuses.find_by(name: 'In Progress')
    done_status = workspace.statuses.find_by(name: 'Done')
    
    if work_category && personal_category && idea_category && backlog_status && todo_status && in_progress_status && done_status
      # Create all sample notes with various dates
      Note.create!(
        title: 'AVA 워크스페이스 사용 가이드',
        body: 'AVA에 오신 것을 환영합니다! 이 노트는 워크스페이스 사용법을 안내합니다.\n\n' \
              '1. 노트: 아이디어와 정보를 기록하세요\n' \
              '2. 칸반: 드래그 앤 드롭으로 작업을 관리하세요\n' \
              '3. 채팅: 팀원들과 실시간으로 소통하세요\n' \
              '4. 캘린더: 일정을 관리하세요\n\n' \
              '좌측 하단의 "샘플 데이터 삭제" 버튼으로 샘플 데이터를 제거할 수 있습니다.',
        category: work_category,
        status: done_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 0,
        start_date: 7.days.ago,
        due_date: 5.days.ago,
        created_at: 7.days.ago
      )
      
      Note.create!(
        title: '첫 번째 프로젝트 기획',
        body: '새로운 프로젝트를 시작해보세요!\n\n' \
              '- 목표 설정\n' \
              '- 일정 계획\n' \
              '- 팀원 배정\n' \
              '- 리소스 확인',
        category: work_category,
        status: todo_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 1,
        start_date: Date.current,
        due_date: 3.days.from_now,
        created_at: 2.days.ago
      )
      
      Note.create!(
        title: '브레인스토밍 아이디어',
        body: '💡 새로운 아이디어들을 자유롭게 적어보세요\n\n' \
              '- 혁신적인 기능\n' \
              '- 사용자 경험 개선\n' \
              '- 프로세스 최적화',
        category: idea_category,
        status: backlog_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 2,
        start_date: 1.week.from_now,
        due_date: 2.weeks.from_now,
        created_at: 1.day.ago
      )
      
      Note.create!(
        title: '주간 업무 보고서 작성',
        body: '이번 주 진행사항을 정리하고 있습니다.\n\n' \
              '✅ 완료된 작업\n' \
              '🔄 진행 중인 작업\n' \
              '📋 다음 주 계획',
        category: work_category,
        status: in_progress_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 3,
        start_date: 2.days.ago,
        due_date: Date.tomorrow,
        created_at: 3.days.ago
      )
      
      Note.create!(
        title: '독서 목록',
        body: '올해 읽고 싶은 책들:\n\n' \
              '📚 클린 코드\n' \
              '📚 리팩토링\n' \
              '📚 도메인 주도 설계\n' \
              '📚 실용주의 프로그래머',
        category: personal_category,
        status: backlog_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 4,
        start_date: 1.month.from_now,
        due_date: 3.months.from_now,
        created_at: 1.week.ago
      )
      
      # Additional 5 notes for Kanban with various dates
      Note.create!(
        title: 'API 문서 작성',
        body: 'REST API 문서를 작성해야 합니다.\n\n' \
              '- 인증 API\n' \
              '- 사용자 관리 API\n' \
              '- 노트 CRUD API\n' \
              '- 채널 관리 API',
        category: work_category,
        status: todo_status,
        user: sample_user1,
        workspace: workspace,
        is_sample: true,
        position: 5,
        start_date: 2.days.from_now,
        due_date: 5.days.from_now,
        created_at: Date.yesterday
      )
      
      Note.create!(
        title: '성능 최적화 검토',
        body: '현재 시스템의 성능을 분석하고 최적화 방안을 찾아보겠습니다.\n\n' \
              '🔍 검토 항목:\n' \
              '- 데이터베이스 쿼리 최적화\n' \
              '- 캐싱 전략 수립\n' \
              '- 이미지 최적화',
        category: work_category,
        status: in_progress_status,
        user: sample_user2,
        workspace: workspace,
        is_sample: true,
        position: 6,
        start_date: Date.yesterday,
        due_date: 4.days.from_now,
        created_at: 3.days.ago
      )
      
      Note.create!(
        title: '팀 빌딩 이벤트 기획',
        body: '다음 달 팀 빌딩 이벤트를 계획합니다.\n\n' \
              '🎉 아이디어:\n' \
              '- 볼링 대회\n' \
              '- 쿠킹 클래스\n' \
              '- 방탈출 게임\n' \
              '- 등산',
        category: idea_category,
        status: backlog_status,
        user: sample_user1,
        workspace: workspace,
        is_sample: true,
        position: 7,
        start_date: 2.weeks.from_now,
        due_date: 3.weeks.from_now,
        created_at: 5.days.ago
      )
      
      Note.create!(
        title: '사용자 피드백 정리',
        body: '최근 수집된 사용자 피드백을 정리합니다.\n\n' \
              '👍 긍정적 피드백:\n' \
              '- UI가 직관적이다\n' \
              '- 속도가 빠르다\n\n' \
              '🔧 개선 요청:\n' \
              '- 다크 모드 지원\n' \
              '- 모바일 앱 개발',
        category: work_category,
        status: done_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 8,
        start_date: 10.days.ago,
        due_date: 3.days.ago,
        created_at: 2.weeks.ago
      )
      
      Note.create!(
        title: '보안 점검 체크리스트',
        body: '분기별 보안 점검 항목입니다.\n\n' \
              '✅ 체크리스트:\n' \
              '- [ ] 비밀번호 정책 검토\n' \
              '- [ ] 접근 권한 확인\n' \
              '- [ ] 보안 패치 적용\n' \
              '- [ ] 백업 상태 확인',
        category: work_category,
        status: todo_status,
        user: sample_user2,
        workspace: workspace,
        is_sample: true,
        position: 9,
        start_date: Date.current,
        due_date: 1.week.from_now,
        created_at: Date.current
      )
      
      puts "Created all sample notes"
    end
    
    puts "Sample data creation completed for AVA workspace!"
  else
    puts "No users found in workspace"
  end
else
  puts "Workspace 'AVA' not found"
end