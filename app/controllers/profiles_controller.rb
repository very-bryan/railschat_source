class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    # full_name을 first_name과 last_name으로 분리
    if params[:user][:full_name].present?
      name_parts = params[:user][:full_name].split(' ', 2)
      params[:user][:first_name] = name_parts[0]
      params[:user][:last_name] = name_parts[1] || ''
      params[:user].delete(:full_name)
    end
    
    if @user.update(user_params)
      redirect_to profile_path, notice: '프로필이 성공적으로 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 트랜잭션으로 묶어서 처리
    ActiveRecord::Base.transaction do
      # 사용자의 콘텐츠를 삭제 또는 익명화 처리
      anonymize_user_content(@user)
      
      # 사용자 계정 삭제
      @user.destroy!
    end
    
    # 세션 종료 및 리다이렉트
    sign_out(@user)
    redirect_to root_path, notice: '계정이 성공적으로 삭제되었습니다.'
  rescue => e
    Rails.logger.error "계정 삭제 중 오류 발생: #{e.message}"
    redirect_to profile_path, alert: '계정 삭제 중 오류가 발생했습니다. 관리자에게 문의해주세요.'
  end

  def notifications
    if @user.update(notification_params)
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'error', errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar)
  end

  def notification_params
    params.permit(:email_notifications, :marketing_emails, :browser_notifications, :quiet_hours)
  end

  def anonymize_user_content(user)
    # 노트 삭제 (NOT NULL 제약 조건 때문에 삭제)
    Note.where(user: user).destroy_all
    
    # 메시지 삭제 (NOT NULL 제약 조건 때문에 삭제)
    if defined?(Message)
      Message.where(user: user).destroy_all
    end
    
    # 댓글 삭제
    if defined?(Comment)
      Comment.where(user: user).destroy_all
    end
    
    # 알림 삭제
    if defined?(Notification)
      Notification.where(user: user).destroy_all
    end
    
    # 채널 멤버십 삭제
    if defined?(ChannelMember)
      ChannelMember.where(user: user).destroy_all
    end
    
    # 워크스페이스 멤버십 삭제
    if defined?(WorkspaceMember)
      WorkspaceMember.where(user: user).destroy_all
    end
  end
end
