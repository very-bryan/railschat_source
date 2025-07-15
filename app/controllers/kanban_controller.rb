class KanbanController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @statuses = Status.where(workspace: current_user.current_workspace).ordered
    @notes_by_status = {}
    
    notes_scope = current_user.notes.where(workspace: current_user.current_workspace)
                            .includes(:category, :assignees, :parent, :children)
    
    if params[:search].present?
      notes_scope = notes_scope.where("title LIKE ? OR body LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    @statuses.each do |status|
      @notes_by_status[status.id] = notes_scope.where(status: status).ordered_by_position
    end
    
    @categories = Category.where(workspace: current_user.current_workspace)
    @users = current_user.current_workspace.users
  end
  
  def update_status
    @note = current_user.notes.find(params[:note_id])
    old_status_id = @note.status_id
    
    ActiveRecord::Base.transaction do
      # Update status
      @note.update!(status_id: params[:status_id])
      
      # Update position if provided
      if params[:position].present?
        new_position = params[:position].to_i
        
        # Get all notes in the new status
        notes_in_status = current_user.notes.where(status_id: params[:status_id])
                                           .where.not(id: @note.id)
                                           .ordered_by_position
        
        # Insert the note at the new position
        notes_in_status.each_with_index do |note, index|
          if index >= new_position
            note.update_column(:position, index + 1)
          else
            note.update_column(:position, index)
          end
        end
        
        @note.update_column(:position, new_position)
      end
      
      # Reorder notes in old status if it's different
      if old_status_id != params[:status_id].to_i
        notes_in_old_status = current_user.notes.where(status_id: old_status_id).ordered_by_position
        notes_in_old_status.each_with_index do |note, index|
          note.update_column(:position, index)
        end
      end
    end
    
    render json: { success: true }
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: '노트를 찾을 수 없습니다.' }
  rescue => e
    render json: { success: false, error: e.message }
  end
end
