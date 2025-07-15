class WorkspaceMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_workspace_admin!
  before_action :set_workspace
  before_action :set_member, only: [:update, :destroy]
  
  def index
    @members = @workspace.workspace_members.includes(:user).order(:role, :joined_at)
    @pending_invitations = [] # 향후 초대 기능 구현 시 사용
  end
  
  def create
    email = params[:email]&.strip
    user = User.find_by(email: email)
    
    if user.nil?
      redirect_to workspace_members_path, alert: '해당 이메일의 사용자를 찾을 수 없습니다.'
      return
    end
    
    if @workspace.users.include?(user)
      redirect_to workspace_members_path, alert: '이미 워크스페이스 멤버입니다.'
      return
    end
    
    @member = @workspace.workspace_members.build(user: user, role: 'member')
    
    if @member.save
      # 알림 생성
      NotificationService.create_notification(
        user: user,
        title: "#{@workspace.name} 워크스페이스에 초대되었습니다",
        body: "#{current_user.name}님이 워크스페이스에 초대했습니다.",
        notification_type: 'channel_invited',
        priority: 3,
        action_url: root_path
      )
      
      redirect_to workspace_members_path, notice: '멤버가 추가되었습니다.'
    else
      redirect_to workspace_members_path, alert: '멤버 추가에 실패했습니다.'
    end
  end
  
  def update
    if @member.user == current_user && params[:role] == 'member'
      redirect_to workspace_members_path, alert: '자신의 관리자 권한은 제거할 수 없습니다.'
      return
    end
    
    if @member.update(role: params[:role])
      redirect_to workspace_members_path, notice: '멤버 권한이 변경되었습니다.'
    else
      redirect_to workspace_members_path, alert: '권한 변경에 실패했습니다.'
    end
  end
  
  def destroy
    if @member.user == current_user
      redirect_to workspace_members_path, alert: '자신은 제거할 수 없습니다.'
      return
    end
    
    @member.destroy
    redirect_to workspace_members_path, notice: '멤버가 제거되었습니다.'
  end
  
  private
  
  def require_workspace_admin!
    unless current_user.workspace_admin?
      redirect_to root_path, alert: '워크스페이스 관리자만 접근할 수 있습니다.'
    end
  end
  
  def set_workspace
    @workspace = current_user.current_workspace
  end
  
  def set_member
    @member = @workspace.workspace_members.find(params[:id])
  end
end