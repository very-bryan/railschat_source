class WorkspaceSetupService
  # Default statuses for all workspaces
  DEFAULT_STATUSES = [
    { name: 'Backlog', color: '#6B7280', position: 0 },
    { name: 'To Do', color: '#3B82F6', position: 1 },
    { name: 'In Progress', color: '#F59E0B', position: 2 },
    { name: 'Review', color: '#8B5CF6', position: 3 },
    { name: 'Pending', color: '#EF4444', position: 4 },
    { name: 'Done', color: '#10B981', position: 5 }
  ].freeze

  # Default categories for all workspaces
  DEFAULT_CATEGORIES = [
    { name: '업무', color: '#3B82F6' },
    { name: '개인', color: '#10B981' },
    { name: '아이디어', color: '#F59E0B' }
  ].freeze

  # Default channels for all workspaces
  DEFAULT_CHANNELS = [
    { name: 'general', description: '팀 전체가 소통하는 공간입니다', is_private: false },
    { name: 'random', description: '자유롭게 대화를 나누는 공간입니다', is_private: false }
  ].freeze

  def self.setup_workspace(workspace, creator)
    new(workspace, creator).setup
  end

  def initialize(workspace, creator)
    @workspace = workspace
    @creator = creator
  end

  def setup
    ActiveRecord::Base.transaction do
      create_default_statuses
      create_default_categories
      create_default_channels
    end
  end

  def create_default_statuses
    DEFAULT_STATUSES.each do |status_attrs|
      Status.find_or_create_by!(
        workspace: @workspace,
        name: status_attrs[:name]
      ) do |status|
        status.color = status_attrs[:color]
        status.position = status_attrs[:position]
      end
    end
  end

  def create_default_categories
    DEFAULT_CATEGORIES.each do |category_attrs|
      Category.find_or_create_by!(
        workspace: @workspace,
        name: category_attrs[:name]
      ) do |category|
        category.color = category_attrs[:color]
      end
    end
  end

  def create_default_channels
    DEFAULT_CHANNELS.each do |channel_attrs|
      channel = Channel.find_or_create_by!(
        workspace: @workspace,
        name: channel_attrs[:name]
      ) do |ch|
        ch.description = channel_attrs[:description]
        ch.is_private = channel_attrs[:is_private]
      end

      # Add creator as member
      ChannelMember.find_or_create_by!(
        channel: channel,
        user: @creator
      ) do |member|
        member.role = 'admin'
      end
    end
  end

  # Update existing workspaces to have all default statuses
  def self.update_all_workspaces
    Workspace.find_each do |workspace|
      puts "Updating workspace: #{workspace.name}"
      
      DEFAULT_STATUSES.each do |status_attrs|
        status = Status.find_or_create_by!(
          workspace: workspace,
          name: status_attrs[:name]
        ) do |s|
          s.color = status_attrs[:color]
          s.position = status_attrs[:position]
        end
        
        # Update position if it already exists
        if status.position != status_attrs[:position]
          status.update!(position: status_attrs[:position])
        end
      end
      
      puts "  - Updated statuses"
    end
  end
end