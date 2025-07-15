class SuperAdmin::DashboardController < SuperAdmin::BaseController
  def index
    # 전체 통계
    @total_workspaces = Workspace.count
    @total_users = User.count
    @total_notes = Note.count
    @total_messages = Message.count
    @total_storage_used = ActiveStorage::Blob.sum(:byte_size)
    
    # 성장 통계 (최근 30일)
    @new_workspaces_30d = Workspace.where(created_at: 30.days.ago..).count
    @new_users_30d = User.where(created_at: 30.days.ago..).count
    @active_users_30d = User.joins(:notes).where(notes: { created_at: 30.days.ago.. }).distinct.count
    
    # 최근 워크스페이스
    @recent_workspaces = Workspace.includes(:users).order(created_at: :desc).limit(10)
    
    # 활성 워크스페이스 (최근 7일간 활동)
    @active_workspaces = Workspace.joins(:notes)
                                  .where(notes: { created_at: 7.days.ago.. })
                                  .group('workspaces.id')
                                  .order('COUNT(notes.id) DESC')
                                  .limit(10)
                                  
    # 일일 가입자 수 (최근 30일)
    users_last_30_days = User.where(created_at: 30.days.ago..)
    @daily_signups = users_last_30_days.group_by { |u| u.created_at.to_date }
                                       .transform_values(&:count)
                                       .transform_keys(&:to_s)
                         
    # 워크스페이스별 사용자 수 분포
    @workspace_size_distribution = {
      '1명' => Workspace.joins(:users).group('workspaces.id').having('COUNT(users.id) = 1').count.size,
      '2-5명' => Workspace.joins(:users).group('workspaces.id').having('COUNT(users.id) BETWEEN 2 AND 5').count.size,
      '6-10명' => Workspace.joins(:users).group('workspaces.id').having('COUNT(users.id) BETWEEN 6 AND 10').count.size,
      '11-20명' => Workspace.joins(:users).group('workspaces.id').having('COUNT(users.id) BETWEEN 11 AND 20').count.size,
      '20명 이상' => Workspace.joins(:users).group('workspaces.id').having('COUNT(users.id) > 20').count.size
    }
  end
end