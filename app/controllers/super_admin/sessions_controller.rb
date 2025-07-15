class SuperAdmin::SessionsController < ApplicationController
  skip_before_action :ensure_workspace
  layout 'super_admin_login'
  
  def new
    redirect_to super_admin_root_path if current_user&.super_admin?
  end
  
  def create
    user = User.find_by(email: params[:email])
    
    if user&.valid_password?(params[:password])
      if user.super_admin?
        sign_in(user)
        redirect_to super_admin_root_path, notice: '슈퍼 관리자로 로그인했습니다.'
      else
        redirect_to new_super_admin_session_path, alert: '슈퍼 관리자 권한이 없습니다.'
      end
    else
      redirect_to new_super_admin_session_path, alert: '이메일 또는 비밀번호가 올바르지 않습니다.'
    end
  end
  
  def destroy
    sign_out current_user
    redirect_to new_super_admin_session_path, notice: '로그아웃했습니다.'
  end
end