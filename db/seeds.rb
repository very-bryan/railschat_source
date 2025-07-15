# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default workflow statuses
default_statuses = [
  { name: 'Backlog', color: '#6b7280', order: 1 },
  { name: 'To Do', color: '#3b82f6', order: 2 },
  { name: 'Doing', color: '#f59e0b', order: 3 },
  { name: 'Pending', color: '#ef4444', order: 4 },
  { name: 'Done', color: '#10b981', order: 5 }
]

default_statuses.each do |status_attrs|
  Status.find_or_create_by!(name: status_attrs[:name], workflow_id: 1) do |status|
    status.color = status_attrs[:color]
    status.order = status_attrs[:order]
  end
end

# Create default categories based on PRD
categories_data = [
  { name: '소프트웨어 개발', color: '#3b82f6', children: [
    { name: '기획·요구사항', color: '#60a5fa' },
    { name: '설계·아키텍처', color: '#93c5fd' },
    { name: '프론트엔드 개발', color: '#dbeafe' },
    { name: '백엔드 개발', color: '#1e40af' },
    { name: 'API·통합', color: '#1e3a8a' },
    { name: '모바일 개발', color: '#312e81' },
    { name: 'DevOps·배포', color: '#7c3aed' },
    { name: 'QA·테스트', color: '#8b5cf6' },
    { name: '보안', color: '#a855f7' },
    { name: '유지보수·버그픽스', color: '#c084fc' }
  ]},
  { name: '마케팅·일반 사무', color: '#10b981', children: [
    { name: '브랜드 전략', color: '#34d399' },
    { name: '디자인', color: '#6ee7b7' },
    { name: '콘텐츠 제작', color: '#a7f3d0' },
    { name: '퍼포먼스 마케팅', color: '#047857' },
    { name: 'PR·커뮤니케이션', color: '#065f46' },
    { name: '이벤트·캠페인', color: '#064e3b' },
    { name: '고객지원·CS', color: '#f59e0b' },
    { name: '영업·파트너십', color: '#d97706' },
    { name: '재무·회계', color: '#b45309' },
    { name: 'HR·채용·복리후생', color: '#92400e' },
    { name: '총무·행정·법무', color: '#78350f' }
  ]},
  { name: '전략·기획', color: '#ef4444', children: [
    { name: '전략 기획', color: '#f87171' },
    { name: '프로젝트 관리', color: '#fca5a5' },
    { name: '시장·경쟁 분석', color: '#fecaca' }
  ]},
  { name: '데이터·AI', color: '#8b5cf6', children: [
    { name: '데이터 엔지니어링', color: '#a78bfa' },
    { name: '데이터 분석·BI', color: '#c4b5fd' },
    { name: '머신러닝·AI', color: '#ddd6fe' },
    { name: '데이터 거버넌스', color: '#ede9fe' }
  ]},
  { name: '고객 성공·지원', color: '#06b6d4', children: [
    { name: '온보딩', color: '#22d3ee' },
    { name: '지원·티켓', color: '#67e8f9' },
    { name: '계정 관리', color: '#a5f3fc' },
    { name: '활용도 분석', color: '#cffafe' }
  ]}
]

categories_data.each do |category_data|
  parent_category = Category.find_or_create_by!(name: category_data[:name]) do |cat|
    cat.color = category_data[:color]
    cat.description = "#{category_data[:name]} 관련 업무"
  end
  
  category_data[:children]&.each do |child_data|
    Category.find_or_create_by!(name: child_data[:name], parent: parent_category) do |child|
      child.color = child_data[:color]
      child.description = "#{child_data[:name]} 관련 업무"
    end
  end
end

# Create default admin user
admin_user = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.role = 'admin'
end

# Create additional test users
test_users = [
  { email: 'developer@example.com', first_name: 'John', last_name: 'Developer', role: 'user' },
  { email: 'designer@example.com', first_name: 'Jane', last_name: 'Designer', role: 'user' },
  { email: 'manager@example.com', first_name: 'Mike', last_name: 'Manager', role: 'user' }
]

test_users.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.first_name = user_data[:first_name]
    user.last_name = user_data[:last_name]
    user.role = user_data[:role]
  end
end

# Create default channels
channels_data = [
  { name: 'general', description: '일반 채널', is_private: false },
  { name: 'development', description: '개발 관련 채널', is_private: false },
  { name: 'design', description: '디자인 관련 채널', is_private: false },
  { name: 'random', description: '자유 채널', is_private: false },
  { name: 'private-team', description: '팀 전용 채널', is_private: true }
]

channels_data.each do |channel_data|
  channel = Channel.find_or_create_by!(name: channel_data[:name]) do |ch|
    ch.description = channel_data[:description]
    ch.is_private = channel_data[:is_private]
  end
  
  # Add admin user to all channels
  ChannelMember.find_or_create_by!(channel: channel, user: admin_user) do |member|
    member.role = 'admin'
  end
  
  # Add other users to public channels
  unless channel.is_private?
    User.where.not(id: admin_user.id).each do |user|
      ChannelMember.find_or_create_by!(channel: channel, user: user) do |member|
        member.role = 'member'
      end
    end
  end
end

# Create sample messages
general_channel = Channel.find_by(name: 'general')
if general_channel
  sample_messages = [
    { content: "안녕하세요! 새로운 채팅 시스템에 오신 것을 환영합니다! 👋", user: admin_user },
    { content: "와 정말 깔끔하네요! 잘 만들어진 것 같습니다.", user: User.find_by(email: 'developer@example.com') },
    { content: "UI도 예쁘고 사용하기 편할 것 같아요!", user: User.find_by(email: 'designer@example.com') },
    { content: "팀 커뮤니케이션이 더 원활해질 것 같습니다.", user: User.find_by(email: 'manager@example.com') }
  ]
  
  sample_messages.each do |message_data|
    Message.find_or_create_by!(
      channel: general_channel,
      user: message_data[:user],
      body: message_data[:content]
    )
  end
end

# Create sample notes with dates for calendar
if admin_user
  categories = Category.all
  statuses = Status.all
  
  sample_notes = [
    {
      title: "프로젝트 킥오프 미팅",
      body: "새로운 프로젝트 시작을 위한 팀 미팅입니다.",
      start_date: Date.current,
      due_date: Date.current + 1.day,
      category: categories.find_by(name: "프로젝트 관리"),
      status: statuses.find_by(name: "To Do")
    },
    {
      title: "API 설계 문서 작성",
      body: "백엔드 API 설계 문서를 작성하고 리뷰받습니다.",
      start_date: Date.current + 2.days,
      due_date: Date.current + 5.days,
      category: categories.find_by(name: "백엔드 개발"),
      status: statuses.find_by(name: "To Do")
    },
    {
      title: "UI/UX 디자인 검토",
      body: "새로운 기능의 UI/UX 디자인을 검토합니다.",
      start_date: Date.current + 3.days,
      due_date: Date.current + 7.days,
      category: categories.find_by(name: "디자인"),
      status: statuses.find_by(name: "Doing")
    },
    {
      title: "데이터베이스 최적화",
      body: "성능 향상을 위한 데이터베이스 쿼리 최적화 작업입니다.",
      start_date: Date.current + 1.week,
      due_date: Date.current + 2.weeks,
      category: categories.find_by(name: "데이터 엔지니어링"),
      status: statuses.find_by(name: "Backlog")
    },
    {
      title: "월간 보고서 작성",
      body: "이번 달 프로젝트 진행 상황을 정리한 보고서를 작성합니다.",
      start_date: Date.current.end_of_month - 2.days,
      due_date: Date.current.end_of_month,
      category: categories.find_by(name: "전략 기획"),
      status: statuses.find_by(name: "To Do")
    },
    {
      title: "마케팅 캠페인 런칭",
      body: "새로운 제품 출시를 위한 마케팅 캠페인을 시작합니다.",
      start_date: Date.current + 10.days,
      due_date: Date.current + 20.days,
      category: categories.find_by(name: "퍼포먼스 마케팅"),
      status: statuses.find_by(name: "To Do")
    },
    {
      title: "고객 피드백 분석",
      body: "최근 수집된 고객 피드백을 분석하고 개선 방안을 도출합니다.",
      start_date: Date.current - 3.days,
      due_date: Date.current + 2.days,
      category: categories.find_by(name: "고객지원·CS"),
      status: statuses.find_by(name: "Doing")
    },
    {
      title: "시스템 보안 점검",
      body: "정기적인 시스템 보안 점검을 수행합니다.",
      start_date: Date.current + 1.week,
      due_date: Date.current + 10.days,
      category: categories.find_by(name: "보안"),
      status: statuses.find_by(name: "To Do")
    }
  ]
  
  sample_notes.each do |note_data|
    next unless note_data[:category] && note_data[:status]
    
    note = Note.find_or_create_by!(
      title: note_data[:title],
      user: admin_user
    ) do |n|
      n.body = note_data[:body]
      n.start_date = note_data[:start_date]
      n.due_date = note_data[:due_date]
      n.category = note_data[:category]
      n.status = note_data[:status]
    end
    
    # Add assignees (assign to admin user)
    note.note_assignees.find_or_create_by!(user: admin_user)
  end
end

puts "Seeded #{Status.count} statuses, #{Category.count} categories, and #{Channel.count} channels"
puts "Created #{User.count} users, #{Message.count} messages, and #{Note.count} notes"
puts "Created admin user: #{admin_user.email}"
