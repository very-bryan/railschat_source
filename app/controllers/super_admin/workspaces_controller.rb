class SuperAdmin::WorkspacesController < SuperAdmin::BaseController
  before_action :set_workspace, only: [:show, :edit, :update, :destroy]
  
  def index
    @workspaces = Workspace.includes(:users).order(created_at: :desc)
    
    # 필터링
    if params[:status].present?
      case params[:status]
      when 'active'
        @workspaces = @workspaces.joins(:notes).where(notes: { created_at: 7.days.ago.. }).distinct
      when 'inactive'
        active_ids = Workspace.joins(:notes).where(notes: { created_at: 7.days.ago.. }).pluck(:id)
        @workspaces = @workspaces.where.not(id: active_ids)
      end
    end
    
    if params[:size].present?
      case params[:size]
      when 'small'
        workspace_ids = WorkspaceMember.group(:workspace_id).having('COUNT(*) <= 5').pluck(:workspace_id)
      when 'medium'
        workspace_ids = WorkspaceMember.group(:workspace_id).having('COUNT(*) BETWEEN 6 AND 20').pluck(:workspace_id)
      when 'large'
        workspace_ids = WorkspaceMember.group(:workspace_id).having('COUNT(*) > 20').pluck(:workspace_id)
      end
      @workspaces = @workspaces.where(id: workspace_ids) if workspace_ids
    end
    
    @workspaces = @workspaces.page(params[:page])
  end
  
  def show
    @members = @workspace.workspace_members.includes(:user)
    @notes_count = @workspace.notes.count
    @messages_count = @workspace.channels.joins(:messages).count
    @storage_used = @workspace.notes.joins(attachments_attachments: :blob).sum('active_storage_blobs.byte_size')
    
    # 활동 통계
    notes_by_day = @workspace.notes.where(created_at: 30.days.ago..)
                            .group_by { |n| n.created_at.to_date }
    @daily_notes = notes_by_day.transform_values(&:count)
                               .transform_keys(&:to_s)
                            
    @recent_notes = @workspace.notes.includes(:user).order(created_at: :desc).limit(10)
    @last_activity = @workspace.notes.maximum(:created_at)
  end
  
  def edit
  end
  
  def update
    if @workspace.update(workspace_params)
      redirect_to super_admin_workspace_path(@workspace), notice: '워크스페이스가 업데이트되었습니다.'
    else
      render :edit
    end
  end
  
  def destroy
    @workspace.destroy
    redirect_to super_admin_workspaces_path, notice: '워크스페이스가 삭제되었습니다.'
  end
  
  private
  
  def set_workspace
    @workspace = Workspace.find(params[:id])
  end
  
  def workspace_params
    params.require(:workspace).permit(:name, :description, :is_active, :max_members, :max_storage_mb)
  end
end