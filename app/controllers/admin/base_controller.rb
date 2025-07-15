class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
  
  layout 'admin'
  
  private
  
  def authenticate_admin!
    redirect_to root_path, alert: '관리자만 접근할 수 있습니다.' unless current_user&.admin?
  end
end