class ChannelReactionsChannel < ApplicationCable::Channel
  def subscribed
    channel = Channel.find(params[:channel_id])
    if channel.channel_members.exists?(user: current_user)
      stream_from "channel_#{channel.id}_reactions"
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
end