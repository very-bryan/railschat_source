class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @date_range = params[:date_range] || '30'
    @start_date = @date_range.to_i.days.ago
    @end_date = Date.current
    
    # Basic statistics
    @total_notes = current_user.notes.count
    @notes_in_range = current_user.notes.where(created_at: @start_date..@end_date).count
    @completed_notes = current_user.notes.joins(:status).where(statuses: { name: 'Done' }).count
    @overdue_notes = current_user.notes.where('due_date < ?', Date.current).joins(:status).where.not(statuses: { name: 'Done' }).count
    
    # Notes by status
    @notes_by_status = current_user.notes.joins(:status).group('statuses.name').count
    
    # Notes by category
    @notes_by_category = current_user.notes.joins(:category).group('categories.name').count
    
    # Daily activity (last 30 days)
    @daily_activity = current_user.notes.where(created_at: 30.days.ago..Date.current)
                                       .group('DATE(created_at)')
                                       .count
    
    # Productivity metrics
    @completion_rate = @total_notes > 0 ? ((@completed_notes.to_f / @total_notes) * 100).round(1) : 0
    @avg_completion_time = calculate_avg_completion_time
    
    # Upcoming deadlines
    @upcoming_deadlines = current_user.notes.where(due_date: Date.current..7.days.from_now)
                                           .joins(:status)
                                           .where.not(statuses: { name: 'Done' })
                                           .order(:due_date)
                                           .limit(10)
    
    # Recent activity
    @recent_notes = current_user.notes.order(created_at: :desc).limit(5)
    
    respond_to do |format|
      format.html
      format.json { render json: report_data }
    end
  end

  def analytics
    @categories = Category.all
    @statuses = Status.all
    
    # Advanced analytics
    @monthly_trends = calculate_monthly_trends
    @category_performance = calculate_category_performance
    @time_distribution = calculate_time_distribution
    @team_productivity = calculate_team_productivity if current_user.role == 'admin'
    
    respond_to do |format|
      format.html
      format.json { render json: analytics_data }
    end
  end

  private

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

  def calculate_monthly_trends
    (0..11).map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month.strftime('%Y-%m'),
        created: current_user.notes.where(created_at: month..month.end_of_month).count,
        completed: current_user.notes.joins(:status)
                                   .where(statuses: { name: 'Done' })
                                   .where(updated_at: month..month.end_of_month)
                                   .count
      }
    end.reverse
  end

  def calculate_category_performance
    Category.joins(:notes)
           .where(notes: { user: current_user })
           .group('categories.name')
           .select('categories.name, categories.color, COUNT(notes.id) as total_notes')
           .map do |category|
      completed = current_user.notes.joins(:status, :category)
                                   .where(statuses: { name: 'Done' }, categories: { name: category.name })
                                   .count
      {
        name: category.name,
        color: category.color,
        total: category.total_notes,
        completed: completed,
        completion_rate: category.total_notes > 0 ? ((completed.to_f / category.total_notes) * 100).round(1) : 0
      }
    end
  end

  def calculate_time_distribution
    {
      morning: current_user.notes.where("EXTRACT(hour FROM created_at) BETWEEN 6 AND 11").count,
      afternoon: current_user.notes.where("EXTRACT(hour FROM created_at) BETWEEN 12 AND 17").count,
      evening: current_user.notes.where("EXTRACT(hour FROM created_at) BETWEEN 18 AND 23").count,
      night: current_user.notes.where("EXTRACT(hour FROM created_at) BETWEEN 0 AND 5").count
    }
  end

  def calculate_team_productivity
    return nil unless current_user.role == 'admin'
    
    User.select('users.*, COUNT(notes.id) as note_count')
        .left_joins(:notes)
        .group('users.id')
        .order('note_count DESC')
        .limit(10)
        .map do |user|
      completed = user.notes.joins(:status).where(statuses: { name: 'Done' }).count
      {
        name: user.full_name.present? ? user.full_name : user.email,
        total_notes: user.note_count,
        completed_notes: completed,
        completion_rate: user.note_count > 0 ? ((completed.to_f / user.note_count) * 100).round(1) : 0
      }
    end
  end

  def report_data
    {
      total_notes: @total_notes,
      completed_notes: @completed_notes,
      completion_rate: @completion_rate,
      overdue_notes: @overdue_notes,
      notes_by_status: @notes_by_status,
      notes_by_category: @notes_by_category,
      daily_activity: @daily_activity
    }
  end

  def analytics_data
    {
      monthly_trends: @monthly_trends,
      category_performance: @category_performance,
      time_distribution: @time_distribution,
      team_productivity: @team_productivity
    }
  end
end
