class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  
  def index
    @user = current_user
    @workspace = current_user.current_workspace
    @categories = Category.all
    @statuses = Status.all
    @channels = current_user.channels
    @user_stats = calculate_user_stats
  end

  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to settings_path, notice: "설정이 성공적으로 업데이트되었습니다."
    else
      @workspace = current_user.current_workspace
      @categories = Category.all
      @statuses = Status.all
      @channels = current_user.channels
      @user_stats = calculate_user_stats
      render :index, alert: "설정 업데이트에 실패했습니다."
    end
  end
  
  def update_workspace
    @workspace = current_user.current_workspace
    
    if @workspace.update(workspace_params)
      redirect_to settings_path, notice: "워크스페이스 설정이 성공적으로 업데이트되었습니다."
    else
      @user = current_user
      @categories = Category.all
      @statuses = Status.all
      @channels = current_user.channels
      @user_stats = calculate_user_stats
      render :index, alert: "워크스페이스 설정 업데이트에 실패했습니다."
    end
  end

  private
  
  def require_admin!
    unless current_user.workspace_admin?
      redirect_to root_path, alert: "권한이 없습니다."
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :timezone, :language, :theme, :email_notifications, :push_notifications)
  end
  
  def workspace_params
    params.require(:workspace).permit(:name, :icon)
  end

  def calculate_user_stats
    {
      total_notes: current_user.notes.count,
      completed_notes: current_user.notes.joins(:status).where(statuses: { name: 'Done' }).count,
      active_channels: current_user.channels.count,
      messages_sent: current_user.messages.count,
      avg_completion_time: calculate_avg_completion_time
    }
  end

  def calculate_avg_completion_time
    completed_notes = current_user.notes.joins(:status)
                                       .where(statuses: { name: 'Done' })
                                       .where.not(start_date: nil)
    
    return 0 if completed_notes.empty?
    
    total_days = completed_notes.sum do |note|
      start_date = note.start_date || note.created_at.to_date
      end_date = note.updated_at.to_date
      (end_date - start_date).to_i
    end
    
    (total_days.to_f / completed_notes.count).round(1)
  end
end
