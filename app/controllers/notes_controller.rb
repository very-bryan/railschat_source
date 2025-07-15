class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy, :update_date]
  
  def index
    @notes = current_user.notes.includes(:category, :status, :assignees, attachments_attachments: :blob)
                        .order(created_at: :desc)
    
    # Apply filters
    @notes = @notes.by_category(params[:category_id]) if params[:category_id].present?
    @notes = @notes.by_status(params[:status_id]) if params[:status_id].present?
    @notes = @notes.where('title LIKE ?', "%#{params[:search]}%") if params[:search].present?
    
    @categories = current_user.current_workspace.categories
    @statuses = current_user.current_workspace.statuses
  end

  def show
  end

  def new
    @note = current_user.notes.build
    @categories = current_user.current_workspace.categories
    @statuses = current_user.current_workspace.statuses
    @users = User.all
  end

  def create
    @note = current_user.notes.build(note_params)
    @note.workspace = current_user.current_workspace
    
    if @note.save
      # Add assignees
      if params[:assignee_ids].present?
        params[:assignee_ids].each do |user_id|
          @note.note_assignees.create(user_id: user_id) if user_id.present?
        end
      end
      
      redirect_to @note, notice: '노트가 성공적으로 생성되었습니다.'
    else
      @categories = Category.all
      @statuses = Status.all
      @users = User.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = current_user.current_workspace.categories
    @statuses = current_user.current_workspace.statuses
    @users = User.all
  end

  def update
    if @note.update(note_params)
      # Update assignees
      @note.note_assignees.destroy_all
      if params[:assignee_ids].present?
        params[:assignee_ids].each do |user_id|
          @note.note_assignees.create(user_id: user_id) if user_id.present?
        end
      end
      
      redirect_to @note, notice: '노트가 성공적으로 수정되었습니다.'
    else
      @categories = Category.all
      @statuses = Status.all
      @users = User.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: '노트가 성공적으로 삭제되었습니다.'
  end
  
  def update_date
    date_type = params[:date_type] # 'start_date' or 'due_date'
    new_date = params[:new_date]
    
    if date_type.in?(['start_date', 'due_date']) && new_date.present?
      if @note.update(date_type => new_date)
        render json: { success: true, message: '날짜가 업데이트되었습니다.' }
      else
        render json: { success: false, errors: @note.errors.full_messages }
      end
    else
      render json: { success: false, error: '잘못된 요청입니다.' }
    end
  end
  
  private
  
  def set_note
    @note = Note.find(params[:id])
  end
  
  def note_params
    params.require(:note).permit(:title, :body, :category_id, :status_id, :start_date, :due_date, :parent_id, attachments: [])
  end
end
