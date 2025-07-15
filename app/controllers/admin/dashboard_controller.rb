class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_workspaces = Workspace.count
    @total_notes = Note.count
    @total_messages = Message.count if defined?(Message)
    
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_notes = Note.includes(:user, :workspace).order(created_at: :desc).limit(5)
    
    # 최근 30일 통계
    @new_users_last_30_days = User.where(created_at: 30.days.ago..Time.current).count
    @new_notes_last_30_days = Note.where(created_at: 30.days.ago..Time.current).count
                        
    # 워크스페이스별 노트 수
    @notes_by_workspace = Note.joins(:workspace)
                              .group('workspaces.name')
                              .count
                              .sort_by { |_, count| -count }
                              .first(5)
  end
end
