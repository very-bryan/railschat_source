class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_channel, except: [:edit, :update, :reactions, :toggle_reaction, :save, :pin, :thread, :share]
  before_action :set_message, only: [:edit, :update, :destroy, :reactions, :toggle_reaction, :save, :pin, :thread, :share]
  before_action :set_channel_for_message, only: [:edit, :update]
  
  def create
    Rails.logger.info "[MessagesController#create] Starting..."
    Rails.logger.info "[MessagesController#create] Params: #{params.inspect}"
    Rails.logger.info "[MessagesController#create] Message params: #{message_params.inspect}"
    
    # Additional security check for note
    if message_params[:note_id].present?
      note = Note.find_by(id: message_params[:note_id])
      if note.nil? || note.workspace_id != @channel.workspace_id
        respond_to do |format|
          format.json { render json: { errors: ["노트를 찾을 수 없거나 접근 권한이 없습니다"] }, status: :forbidden }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "messages/form", locals: { channel: @channel, message: Message.new }) }
          format.html { redirect_to chat_channel_path(@channel), alert: "노트를 찾을 수 없거나 접근 권한이 없습니다" }
        end
        return
      end
    end
    
    @message = @channel.messages.build(message_params)
    @message.user = current_user
    
    Rails.logger.info "[MessagesController#create] Message before save: #{@message.inspect}"
    
    # Set thread root if this is a reply
    if @message.parent_message_id.present?
      Rails.logger.info "[MessagesController#create] This is a thread reply, parent_message_id: #{@message.parent_message_id}"
      parent = Message.find(@message.parent_message_id)
      @message.thread_root_id = parent.thread_root_id || parent.id
      Rails.logger.info "[MessagesController#create] Set thread_root_id to: #{@message.thread_root_id}"
    end
    
    if @message.save
      # Create notification for thread reply
      if @message.parent_message_id.present?
        create_reply_notifications(@message)
      end
      
      # Broadcast unread count to other channel members
      broadcast_unread_counts
      
      respond_to do |format|
        format.turbo_stream
        # The turbo_stream format will automatically render create.turbo_stream.erb
        format.html { redirect_to chat_channel_path(@channel) }
        format.json { render json: { status: 'ok', message: @message } }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("new_message", partial: "messages/form", locals: { channel: @channel, message: @message })
        end
        format.html do
          @messages = @channel.messages.includes(:user).order(created_at: :asc)
          render 'chat/show', alert: "메시지 전송에 실패했습니다."
        end
        format.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
  
  def edit
    if @message.user != current_user
      redirect_to chat_channel_path(@channel), alert: "권한이 없습니다."
      return
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    Rails.logger.info "[MessagesController#update] @channel: #{@channel.inspect}"
    Rails.logger.info "[MessagesController#update] @message: #{@message.inspect}"
    
    if @message.user != current_user
      redirect_to chat_channel_path(@channel), alert: "권한이 없습니다."
      return
    end

    if @message.update(message_params.merge(edited_at: Time.current))
      Rails.logger.info "[MessagesController#update] Message updated successfully"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_channel_path(@channel) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-#{@message.id}", partial: "messages/message_grouped", locals: { message: @message, previous_message: nil }) }
        format.html { redirect_to chat_channel_path(@channel), alert: "메시지 수정에 실패했습니다." }
      end
    end
  end

  def destroy
    # Check if channel_id is in params (nested route)
    if params[:channel_id]
      @channel = current_user.channels.find(params[:channel_id])
      @message = @channel.messages.find(params[:id])
    else
      # Fallback for non-nested route
      @message = Message.find(params[:id])
      @channel = @message.channel
      
      # Verify user has access to this channel
      unless current_user.channels.include?(@channel)
        redirect_to chat_index_path, alert: "권한이 없습니다."
        return
      end
    end
    
    if @message.user == current_user
      @message.destroy
      
      # Broadcast unread count update after deletion
      broadcast_unread_counts
      
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("message-#{@message.id}") }
        format.html { redirect_to chat_channel_path(@channel), notice: "메시지가 삭제되었습니다." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to chat_channel_path(@channel), alert: "권한이 없습니다." }
        format.json { render json: { error: "권한이 없습니다" }, status: :forbidden }
      end
    end
  end
  
  def reactions
    @reaction = @message.reactions.find_or_initialize_by(user: current_user, emoji: params[:emoji])
    
    if @reaction.persisted?
      @reaction.destroy
    else
      @reaction.save
    end
    
    respond_to do |format|
      format.turbo_stream { render_reaction_update }
      format.json { render json: { status: 'ok' } }
    end
  end
  
  def toggle_reaction
    reactions
  end
  
  def save
    @saved_message = current_user.saved_messages.find_or_initialize_by(message: @message)
    
    if @saved_message.persisted?
      @saved_message.destroy
      message = "저장이 취소되었습니다"
    else
      @saved_message.save
      message = "메시지가 저장되었습니다"
    end
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.append("notifications", partial: "shared/toast", locals: { message: message }) }
      format.json { render json: { status: 'ok', saved: @saved_message.persisted? } }
    end
  end
  
  def pin
    if current_user.workspace_admin? || @message.user == current_user
      if @message.is_pinned?
        @message.unpin!
        message = "고정이 해제되었습니다"
      else
        @message.pin!
        message = "메시지가 고정되었습니다"
      end
      
      respond_to do |format|
        format.turbo_stream # This will render pin.turbo_stream.erb
        format.json { render json: { status: 'ok', pinned: @message.is_pinned? } }
      end
    else
      render json: { error: '권한이 없습니다' }, status: :forbidden
    end
  end
  
  def thread
    # Get the thread root message
    thread_root = @message.thread_root? ? @message : @message.thread_root
    
    # Get all messages in the thread
    thread_messages = thread_root.thread_messages.includes(:user).order(:created_at)
    
    render json: {
      original_message: {
        id: thread_root.id,
        body: thread_root.body,
        body_html: thread_root.body_with_mentions_html,
        created_at: thread_root.created_at,
        user_name: thread_root.user.name,
        user_avatar_url: thread_root.user.avatar_url
      },
      thread_messages: thread_messages.map do |msg|
        {
          id: msg.id,
          body: msg.body,
          body_html: msg.body_with_mentions_html,
          created_at: msg.created_at,
          user_name: msg.user.name,
          user_avatar_url: msg.user.avatar_url
        }
      end
    }
  end
  
  def share
    target_channel_id = params[:target_channel_id]
    target_channel = current_user.channels.find(target_channel_id)
    
    # Check if user has access to target channel
    unless current_user.channels.include?(target_channel)
      render json: { error: '해당 채널에 접근 권한이 없습니다' }, status: :forbidden
      return
    end
    
    # Share the message to the target channel
    shared_message = @message.share_to_channel(target_channel, current_user)
    
    if shared_message.persisted?
      render json: { status: 'ok', message_id: shared_message.id }
    else
      render json: { error: '메시지 공유에 실패했습니다' }, status: :unprocessable_entity
    end
  end

  private

  def set_channel
    channel_id = params[:channel_id] || params[:id]
    Rails.logger.info "[set_channel] Looking for channel with id: #{channel_id}"
    Rails.logger.info "[set_channel] Params: #{params.inspect}"
    
    @channel = current_user.channels.find(channel_id)
    Rails.logger.info "[set_channel] Found channel: #{@channel.inspect}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "[set_channel] Channel not found"
    redirect_to chat_index_path, alert: "채널을 찾을 수 없습니다."
  end
  
  def set_message
    @message = Message.find(params[:id])
  end

  def set_channel_for_message
    @channel = @message.channel if @message
  end

  def message_params
    params.require(:message).permit(:body, :parent_message_id, :note_id, attachments: [])
  end
  
  def create_reply_notifications(message)
    # Get the thread root message
    thread_root = message.thread_root_id ? Message.find(message.thread_root_id) : message.parent_message
    
    # Notify the original message author
    if thread_root.user != current_user
      NotificationService.create_notification(
        user: thread_root.user,
        notification_type: 'message_reply',
        title: "#{current_user.name}님이 답글을 남겼습니다",
        body: message.body.truncate(100),
        action_url: chat_channel_path(@channel),
        priority: 3,
        related: message
      )
    end
    
    # Notify other participants in the thread
    thread_participants = Message.where(thread_root_id: thread_root.id)
                                 .where.not(user_id: [current_user.id, thread_root.user_id])
                                 .distinct
                                 .pluck(:user_id)
    
    User.where(id: thread_participants).each do |participant|
      NotificationService.create_notification(
        user: participant,
        notification_type: 'message_reply',
        title: "#{current_user.name}님이 스레드에 답글을 남겼습니다",
        body: message.body.truncate(100),
        action_url: chat_channel_path(@channel),
        priority: 3,
        related: message
      )
    end
  end
  
  def render_reaction_update
    render turbo_stream: turbo_stream.replace(
      "message-#{@message.id}",
      partial: "messages/message",
      locals: { message: @message }
    )
  end
  
  def render_pin_update
    streams = [
      turbo_stream.replace(
        "message-#{@message.id}",
        partial: "messages/message",
        locals: { message: @message }
      )
    ]
    
    if @message.is_pinned?
      streams << turbo_stream.prepend(
        "pinned-messages",
        partial: "messages/pinned_message",
        locals: { message: @message }
      )
    end
    
    render turbo_stream: streams
  end
  
  def broadcast_unread_counts
    @channel.users.where.not(id: current_user.id).each do |user|
      ActionCable.server.broadcast(
        "user_#{user.id}_unread",
        {
          action: 'update_unread_count',
          channel_id: @channel.id,
          unread_count: @channel.unread_messages_count_for(user)
        }
      )
    end
  end
end
