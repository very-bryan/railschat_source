class Admin::WorkspacesController < Admin::BaseController
  before_action :set_workspace, only: [:show, :edit, :update, :destroy]
  
  def index
    @workspaces = Workspace.includes(:users).order(created_at: :desc)
  end

  def show
    @members = @workspace.user_workspaces.includes(:user)
    @notes = @workspace.notes.includes(:user).order(created_at: :desc).limit(10)
  end

  def edit
  end

  def update
    if @workspace.update(workspace_params)
      redirect_to admin_workspace_path(@workspace), notice: '워크스페이스가 성공적으로 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @workspace.destroy
    redirect_to admin_workspaces_path, notice: '워크스페이스가 성공적으로 삭제되었습니다.'
  end
  
  private
  
  def set_workspace
    @workspace = Workspace.find(params[:id])
  end
  
  def workspace_params
    params.require(:workspace).permit(:name, :description)
  end
end