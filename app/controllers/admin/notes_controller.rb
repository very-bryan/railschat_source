class Admin::NotesController < Admin::BaseController
  before_action :set_note, only: [:show, :destroy]
  
  def index
    @notes = Note.includes(:user, :workspace).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def destroy
    @note.destroy
    redirect_to admin_notes_path, notice: '노트가 성공적으로 삭제되었습니다.'
  end
  
  private
  
  def set_note
    @note = Note.find(params[:id])
  end
end