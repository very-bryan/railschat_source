namespace :sample_data do
  desc "Create sample data for a workspace"
  task :create, [:workspace_name] => :environment do |t, args|
    workspace_name = args[:workspace_name] || 'verychat'
    workspace = Workspace.find_by(name: workspace_name)
    
    unless workspace
      puts "Workspace '#{workspace_name}' not found!"
      next
    end
    
    user = workspace.users.first
    
    unless user
      puts "No users found in workspace '#{workspace_name}'!"
      next
    end
    
    puts "Creating sample data for workspace: #{workspace.name}"
    
    # Create sample users if they don't exist
    sample_user1 = User.find_or_create_by!(email: "sample_kim_#{workspace.id}@example.com") do |u|
      u.password = SecureRandom.hex(10)
      u.first_name = "지민"
      u.last_name = "김"
      u.current_workspace = workspace
    end
    
    sample_user2 = User.find_or_create_by!(email: "sample_lee_#{workspace.id}@example.com") do |u|
      u.password = SecureRandom.hex(10)
      u.first_name = "서연"
      u.last_name = "이"
      u.current_workspace = workspace
    end
    
    # Add sample users to workspace if not already members
    WorkspaceMember.find_or_create_by!(workspace: workspace, user: sample_user1) do |member|
      member.role = 'member'
    end
    WorkspaceMember.find_or_create_by!(workspace: workspace, user: sample_user2) do |member|
      member.role = 'member'
    end
    
    # Create sample channels if they don't exist
    general_channel = workspace.channels.find_or_create_by!(name: 'general') do |channel|
      channel.description = '팀 전체가 소통하는 공간입니다'
    end
    
    random_channel = workspace.channels.find_or_create_by!(name: 'random') do |channel|
      channel.description = '자유롭게 대화를 나누는 공간입니다'
    end
    
    # Add all users to channels if not already members
    [user, sample_user1, sample_user2].each do |u|
      ChannelMember.find_or_create_by!(channel: general_channel, user: u) do |member|
        member.role = 'member'
      end
      ChannelMember.find_or_create_by!(channel: random_channel, user: u) do |member|
        member.role = 'member'
      end
    end
    
    # Create sample categories
    work_category = workspace.categories.find_or_create_by!(name: '업무') do |cat|
      cat.color = '#3B82F6'
    end
    
    personal_category = workspace.categories.find_or_create_by!(name: '개인') do |cat|
      cat.color = '#10B981'
    end
    
    idea_category = workspace.categories.find_or_create_by!(name: '아이디어') do |cat|
      cat.color = '#F59E0B'
    end
    
    # Create sample statuses
    backlog_status = workspace.statuses.find_or_create_by!(name: 'Backlog') do |status|
      status.color = '#6B7280'
      status.position = 0
    end
    
    todo_status = workspace.statuses.find_or_create_by!(name: 'To Do') do |status|
      status.color = '#3B82F6'
      status.position = 1
    end
    
    in_progress_status = workspace.statuses.find_or_create_by!(name: 'In Progress') do |status|
      status.color = '#F59E0B'
      status.position = 2
    end
    
    done_status = workspace.statuses.find_or_create_by!(name: 'Done') do |status|
      status.color = '#10B981'
      status.position = 3
    end
    
    # Create sample notes
    Note.create!(
      title: '워크스페이스 사용 가이드',
      body: '환영합니다! 이 노트는 워크스페이스 사용법을 안내합니다.\n\n' \
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
      position: 0
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
      position: 1
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
      position: 2
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
      position: 3
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
      position: 4
    )
    
    # Additional sample notes for Kanban
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
      position: 5
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
      position: 6
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
      position: 7
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
      position: 8
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
      position: 9
    )
    
    # Create sample messages
    Message.create!(
      body: '안녕하세요! 워크스페이스에 오신 것을 환영합니다 👋',
      user: sample_user1,
      channel: general_channel,
      is_sample: true
    )
    
    Message.create!(
      body: '이곳은 팀 전체가 소통하는 #general 채널입니다. 중요한 공지사항이나 전체 논의가 필요한 내용을 공유해주세요.',
      user: user,
      channel: general_channel,
      is_sample: true
    )
    
    Message.create!(
      body: '반갑습니다! 잘 부탁드려요 😊',
      user: sample_user2,
      channel: general_channel,
      is_sample: true
    )
    
    Message.create!(
      body: '오늘 날씨가 정말 좋네요! ☀️',
      user: sample_user1,
      channel: random_channel,
      is_sample: true
    )
    
    Message.create!(
      body: '맞아요! 점심시간에 산책하면 좋을 것 같아요 🚶‍♀️',
      user: sample_user2,
      channel: random_channel,
      is_sample: true
    )
    
    # Additional messages for more realistic conversation
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
    
    puts "Sample data created successfully!"
  end
end