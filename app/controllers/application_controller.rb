class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_workspace, if: :user_signed_in?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end
  
  def ensure_workspace
    return if controller_name == 'workspaces'
    return if controller_name == 'omniauth_callbacks'
    return if self.class.to_s.start_with?('SuperAdmin::')
    return if self.class.to_s.start_with?('Admin::')
    
    if current_user.workspaces.empty?
      session[:pending_user_id] = current_user.id
      sign_out current_user
      redirect_to new_workspace_path
    elsif current_user.current_workspace.nil?
      current_user.update(current_workspace: current_user.workspaces.first)
    end
  end
end
