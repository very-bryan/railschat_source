class SuperAdmin::AnalyticsController < SuperAdmin::BaseController
  def index
    # User analytics
    @total_users = User.count
    @active_users_7d = User.joins(:notes).where(notes: { created_at: 7.days.ago.. }).distinct.count
    @active_users_30d = User.joins(:notes).where(notes: { created_at: 30.days.ago.. }).distinct.count
    
    # Content analytics
    @total_notes = Note.count
    @notes_created_30d = Note.where(created_at: 30.days.ago..).count
    @total_attachments = ActiveStorage::Attachment.count
    @total_storage_used = ActiveStorage::Blob.sum(:byte_size)
    
    # Engagement analytics
    @messages_sent_30d = Message.where(created_at: 30.days.ago..).count
    @comments_created_30d = Comment.where(created_at: 30.days.ago..).count
    
    # Growth analytics
    # 월별 사용자 증가
    users_by_month = User.where(created_at: 12.months.ago..)
                         .group_by { |u| u.created_at.beginning_of_month }
    @user_growth_by_month = users_by_month.transform_values(&:count)
                                          .transform_keys { |k| k.strftime('%Y-%m') }
    
    # 월별 워크스페이스 증가
    workspaces_by_month = Workspace.where(created_at: 12.months.ago..)
                                   .group_by { |w| w.created_at.beginning_of_month }
    @workspace_growth_by_month = workspaces_by_month.transform_values(&:count)
                                                    .transform_keys { |k| k.strftime('%Y-%m') }
    
    # 일별 노트 생성
    notes_by_day = Note.where(created_at: 30.days.ago..)
                       .group_by { |n| n.created_at.to_date }
    @notes_by_day = notes_by_day.transform_values(&:count)
                                .transform_keys(&:to_s)
    
    # Top workspaces by activity
    @top_workspaces = Workspace.joins(:notes)
                               .where(notes: { created_at: 30.days.ago.. })
                               .group('workspaces.id')
                               .order('COUNT(notes.id) DESC')
                               .limit(10)
                               .pluck('workspaces.name', 'workspaces.id', 'COUNT(notes.id)')
  end
end