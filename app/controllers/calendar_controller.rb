class CalendarController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @start_date = @date.beginning_of_month.beginning_of_week
    @end_date = @date.end_of_month.end_of_week
    
    # Get notes for the current month view
    notes_scope = current_user.notes.includes(:category, :status, :assignees)
    
    if params[:search].present?
      notes_scope = notes_scope.where("title LIKE ? OR body LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    @notes = notes_scope.where(
                          "(notes.start_date BETWEEN ? AND ?) OR (notes.due_date BETWEEN ? AND ?) OR (notes.created_at BETWEEN ? AND ?)",
                          @start_date, @end_date, @start_date, @end_date, @start_date, @end_date
                        )
                        .order("notes.start_date", "notes.due_date", "notes.created_at")
    
    # Group notes by date for calendar display
    @notes_by_date = {}
    @notes.each do |note|
      dates = []
      dates << note.start_date if note.start_date
      dates << note.due_date if note.due_date
      dates << note.created_at.to_date if dates.empty?
      
      dates.each do |date|
        next unless date.between?(@start_date, @end_date)
        @notes_by_date[date] ||= []
        @notes_by_date[date] << note unless @notes_by_date[date].include?(note)
      end
    end
    
    @categories = Category.all
    @statuses = Status.all
  end
end
