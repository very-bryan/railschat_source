class SessionsController < ApplicationController
  def destroy
    sign_out current_user if user_signed_in?
    redirect_to new_user_session_path, notice: '로그아웃되었습니다.'
  end
end