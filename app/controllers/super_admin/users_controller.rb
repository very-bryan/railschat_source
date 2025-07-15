class SuperAdmin::UsersController < SuperAdmin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_super_admin, :impersonate]
  
  def index
    @users = User.includes(:workspaces).order(created_at: :desc)
    
    # 검색
    if params[:q].present?
      @users = @users.where("email LIKE ? OR first_name LIKE ? OR last_name LIKE ?", 
                           "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    
    # 필터
    if params[:role].present?
      case params[:role]
      when 'super_admin'
        @users = @users.where(super_admin: true)
      when 'admin'
        @users = @users.where(admin: true, super_admin: false)
      when 'user'
        @users = @users.where(admin: false, super_admin: false)
      end
    end
    
    @users = @users.page(params[:page])
  end
  
  def show
    @workspaces = @user.workspaces
    @notes_count = @user.notes.count
    @messages_count = @user.messages.count
    @last_activity = [@user.notes.maximum(:created_at), @user.messages.maximum(:created_at)].compact.max
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to super_admin_user_path(@user), notice: '사용자 정보가 업데이트되었습니다.'
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    redirect_to super_admin_users_path, notice: '사용자가 삭제되었습니다.'
  end
  
  def toggle_super_admin
    @user.update(super_admin: !@user.super_admin?)
    redirect_back(fallback_location: super_admin_users_path, 
                  notice: "#{@user.email}의 슈퍼 관리자 권한이 #{@user.super_admin? ? '부여' : '제거'}되었습니다.")
  end
  
  def impersonate
    session[:admin_id] = current_user.id
    sign_in(:user, @user)
    redirect_to root_path, notice: "#{@user.email}로 로그인했습니다."
  end
  
  def stop_impersonating
    return unless session[:admin_id]
    
    admin = User.find(session[:admin_id])
    sign_in(:user, admin)
    session.delete(:admin_id)
    redirect_to super_admin_root_path, notice: "관리자 계정으로 복귀했습니다."
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :admin, :super_admin)
  end
end