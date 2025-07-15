class SuperAdmin::BaseController < ApplicationController
  skip_before_action :ensure_workspace
  before_action :authenticate_super_admin!
  
  layout 'super_admin'
  
  private
  
  def authenticate_super_admin!
    if !user_signed_in?
      redirect_to super_admin_new_session_path, alert: '로그인이 필요합니다.'
    elsif !current_user.super_admin?
      redirect_to root_path, alert: '접근 권한이 없습니다.'
    end
  end
end