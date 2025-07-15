class MessageReadChannel < ApplicationCable::Channel
  def subscribed
    return unless params[:channel_id].present?
    
    @channel = current_user.channels.find_by(id: params[:channel_id])
    return unless @channel
    
    stream_from "channel_#{@channel.id}_reads"
    
    # Mark all existing messages in the channel as read immediately
    mark_channel_messages_as_read
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def mark_as_read(data)
    return unless data['message_id'].present?
    
    message = @channel.messages.find_by(id: data['message_id'])
    return unless message
    
    # Mark message as read
    message.mark_as_read_by(current_user)
    
    # Broadcast read status to other users
    ActionCable.server.broadcast(
      "channel_#{@channel.id}_reads",
      {
        action: 'message_read',
        message_id: message.id,
        user_id: current_user.id,
        readers_count: message.readers.count
      }
    )
    
    # Also broadcast to update unread count for this user
    broadcast_unread_count
  end
  
  private
  
  def mark_channel_messages_as_read
    Rails.logger.info "[MessageReadChannel] Marking all messages as read for user #{current_user.id} in channel #{@channel.id}"
    
    unread_messages = @channel.messages.where.not(id: current_user.read_messages.pluck(:id))
    Rails.logger.info "[MessageReadChannel] Found #{unread_messages.count} unread messages"
    
    unread_messages.find_each do |message|
      message.mark_as_read_by(current_user)
    end
    
    # Broadcast updated unread count immediately
    new_count = @channel.unread_messages_count_for(current_user)
    Rails.logger.info "[MessageReadChannel] New unread count: #{new_count}"
    
    broadcast_unread_count
  end
  
  def broadcast_unread_count
    ActionCable.server.broadcast(
      "user_#{current_user.id}_unread",
      {
        action: 'update_unread_count',
        channel_id: @channel.id,
        unread_count: @channel.unread_messages_count_for(current_user)
      }
    )
  end
end
