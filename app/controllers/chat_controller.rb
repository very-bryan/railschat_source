class ChatController < ApplicationController
  before_action :authenticate_user!
  before_action :set_channel, only: [:show]
  
  def index
    workspace = current_user.current_workspace
    @channels = current_user.channels
                           .where(workspace: workspace)
                           .includes(:channel_members, :messages)
                           .left_joins(:channel_members)
                           .group('channels.id')
                           .order('COUNT(channel_members.id) DESC')
    
    # 가장 최근에 메시지가 있는 채널 찾기
    @current_channel = current_user.channels
                                  .where(workspace: workspace)
                                  .joins(:messages)
                                  .order('messages.created_at DESC')
                                  .first || current_user.channels.where(workspace: workspace).first
    
    if @current_channel
      @messages = @current_channel.messages.includes(:user, :parent_message, { reactions: :user }, { thread_messages: [:user, { reactions: :user }] }).order(created_at: :asc).last(50)
      @pinned_messages = @current_channel.messages.pinned.includes(:user)
      @message = Message.new
    else
      @messages = []
      @pinned_messages = []
    end
    
    @recent_messages = Message.joins(:channel)
                             .where(channels: { id: current_user.channels.where(workspace: workspace).pluck(:id) })
                             .includes(:user, :channel)
                             .order(created_at: :desc)
                             .limit(50)
    @all_users = workspace.users.where.not(id: current_user.id)
  end

  def show
    workspace = current_user.current_workspace
    @current_channel = @channel  # Set @current_channel for consistency with index view
    @channels = current_user.channels
                           .where(workspace: workspace)
                           .includes(:channel_members, :messages)
                           .left_joins(:channel_members)
                           .group('channels.id')
                           .order('COUNT(channel_members.id) DESC')
    @messages = @channel.messages.includes(:user, :parent_message, { reactions: :user }, { thread_messages: [:user, { reactions: :user }] }).order(created_at: :asc)
    @pinned_messages = @channel.messages.pinned.includes(:user)
    @message = Message.new
    @all_users = workspace.users.where.not(id: current_user.id)
    
    # Mark all messages in this channel as read for current user
    mark_channel_messages_as_read
  end

  private

  def set_channel
    @channel = current_user.channels.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to chat_index_path, alert: "채널을 찾을 수 없습니다."
  end
  
  def mark_channel_messages_as_read
    # Get unread messages
    unread_messages = @channel.messages.where.not(id: current_user.read_messages.pluck(:id))
    
    Rails.logger.info "[ChatController] Marking #{unread_messages.count} messages as read in channel #{@channel.id}"
    
    # Mark all as read
    unread_messages.find_each do |message|
      message.mark_as_read_by(current_user)
    end
    
    # Broadcast updated unread count
    ActionCable.server.broadcast(
      "user_#{current_user.id}_unread",
      {
        action: 'update_unread_count',
        channel_id: @channel.id,
        unread_count: 0
      }
    )
  end
end
