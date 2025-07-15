class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [:destroy]
  
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back(fallback_location: root_path, notice: '댓글이 작성되었습니다.') }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_comment", partial: "comments/form", locals: { commentable: @commentable, comment: @comment }) }
        format.html { redirect_back(fallback_location: root_path, alert: '댓글 작성에 실패했습니다.') }
      end
    end
  end
  
  def destroy
    if @comment.user == current_user || current_user.admin?
      @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back(fallback_location: root_path, notice: '댓글이 삭제되었습니다.') }
      end
    else
      redirect_back(fallback_location: root_path, alert: '권한이 없습니다.')
    end
  end
  
  private
  
  def set_commentable
    if params[:note_id]
      @commentable = Note.find(params[:note_id])
    end
  end
  
  def set_comment
    @comment = @commentable.comments.find(params[:id])
  end
  
  def comment_params
    params.require(:comment).permit(:content, attachments: [])
  end
end