class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:show, :update, :destroy]
  
  def index
    @notifications = current_user.notifications.recent.includes(:related)
    @unread_count = current_user.notifications.unread.count
    @filter = params[:filter] || 'unread'  # 기본값을 'unread'로 변경
    @search = params[:search]
    
    # 각 필터별 카운트 계산
    base_notifications = current_user.notifications
    if @search.present?
      base_notifications = base_notifications.where("title LIKE ? OR body LIKE ?", "%#{@search}%", "%#{@search}%")
    end
    
    @unread_filter_count = base_notifications.unread.count
    @chat_unread_count = base_notifications.unread.where(notification_type: ['message_received', 'message_reply', 'message_mention', 'channel_invited']).count
    @note_unread_count = base_notifications.unread.where(notification_type: ['note_assigned', 'note_due_soon', 'note_overdue', 'note_completed', 'note_commented']).count
    @system_unread_count = base_notifications.unread.where(notification_type: ['system_announcement', 'task_reminder']).count
    
    # 검색 적용
    if @search.present?
      @notifications = @notifications.where("title LIKE ? OR body LIKE ?", "%#{@search}%", "%#{@search}%")
    end
    
    case @filter
    when 'unread'
      @notifications = @notifications.unread
    when 'read'
      @notifications = @notifications.read
    when 'chat'
      @notifications = @notifications.where(notification_type: ['message_received', 'message_reply', 'message_mention', 'channel_invited'])
    when 'note'
      @notifications = @notifications.where(notification_type: ['note_assigned', 'note_due_soon', 'note_overdue', 'note_completed', 'note_commented'])
    when 'system'
      @notifications = @notifications.where(notification_type: ['system_announcement', 'task_reminder'])
    when 'all'
      # 전체 표시
    end
    
    @notifications = @notifications.page(params[:page]).per(20)
  end

  def show
    @notification.mark_as_read! unless @notification.read?
    
    if @notification.action_url.present?
      redirect_to @notification.action_url
    else
      redirect_to notifications_path
    end
  end

  def update
    if params[:mark_as_read]
      @notification.mark_as_read!
    elsif params[:mark_as_unread]
      @notification.mark_as_unread!
    end
    
    redirect_to notifications_path
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: "알림이 삭제되었습니다."
  end

  def mark_all_read
    # update_all 대신 각각 update를 호출하여 콜백이 실행되도록 함
    current_user.notifications.unread.find_each do |notification|
      notification.mark_as_read!
    end
    redirect_to notifications_path, notice: "모든 알림을 읽음으로 표시했습니다."
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
