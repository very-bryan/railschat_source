class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # Check if user has any workspace
      if @user.workspaces.empty?
        # Store user_id in session to use after workspace creation
        session[:pending_user_id] = @user.id
        redirect_to new_workspace_path
      else
        # Set current workspace if not set
        @user.update(current_workspace: @user.workspaces.first) unless @user.current_workspace
        
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      end
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: "회원가입 중 오류가 발생했습니다."
    end
  end

  def failure
    redirect_to root_path, alert: "인증에 실패했습니다."
  end
end