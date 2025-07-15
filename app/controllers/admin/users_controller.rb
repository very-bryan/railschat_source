class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_admin]
  
  def index
    @users = User.includes(:workspaces).order(created_at: :desc)
  end

  def show
    @notes = @user.notes.includes(:workspace).order(created_at: :desc).limit(10)
    @workspaces = @user.workspaces
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: '사용자 정보가 성공적으로 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: '사용자가 성공적으로 삭제되었습니다.'
  end

  def toggle_admin
    @user.update(admin: !@user.admin?)
    redirect_back(fallback_location: admin_users_path, notice: '관리자 권한이 변경되었습니다.')
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role)
  end
end