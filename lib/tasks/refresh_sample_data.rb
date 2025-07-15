# Script to refresh sample data for ava workspace
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
  
  # Create new sample data
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
      
      # Create sample messages with new names
      Message.create!(
        body: '안녕하세요! AVA 워크스페이스에 오신 것을 환영합니다 👋',
        user: sample_user1,
        channel: general_channel,
        is_sample: true
      )
      
      Message.create!(
        body: 'AVA에서 함께 일하게 되어 기쁩니다. 잘 부탁드려요!',
        user: sample_user2,
        channel: general_channel,
        is_sample: true
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
      
      puts "Created new sample messages"
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
      # Create sample notes
      Note.create!(
        title: 'AVA 워크스페이스 사용 가이드',
        body: 'AVA에 오신 것을 환영합니다! 이 노트는 워크스페이스 사용법을 안내합니다.\n\n' \
              '1. 노트: 아이디어와 정보를 기록하세요\n' \
              '2. 칸반: 드래그 앤 드롭으로 작업을 관리하세요\n' \
              '3. 채팅: 팀원들과 실시간으로 소통하세요\n' \
              '4. 캘린더: 일정을 관리하세요',
        category: work_category,
        status: done_status,
        user: user,
        workspace: workspace,
        is_sample: true,
        position: 0
      )
      
      puts "Created sample notes"
    end
    
    puts "Sample data refresh completed for AVA workspace!"
  else
    puts "No users found in workspace"
  end
else
  puts "Workspace 'ava' not found"
end