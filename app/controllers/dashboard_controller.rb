class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # 다가오는 마감일 (7일 이내)
    @upcoming_deadlines = Note.includes(:category, :status)
                              .where(workspace: current_user.current_workspace)
                              .where.not(due_date: nil)
                              .where(due_date: Date.today..7.days.from_now)
                              .where.not(status: Status.find_by(name: 'Done'))
                              .order(:due_date)
                              .limit(5)
    
    # 최근 활동 (최근 생성된 노트)
    @recent_notes = Note.includes(:category, :status, :user)
                        .where(workspace: current_user.current_workspace)
                        .order(created_at: :desc)
                        .limit(5)
  end
end
