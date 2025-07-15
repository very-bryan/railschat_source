class NotePresenceChannel < ApplicationCable::Channel
  def subscribed
    @note = Note.find(params[:note_id])
    stream_for @note
    
    # Add user to viewers
    viewers[params[:note_id]] ||= []
    viewers[params[:note_id]] << viewer_data
    
    # Broadcast updated viewers list
    broadcast_viewers
  end

  def unsubscribed
    # Remove user from viewers
    viewers[params[:note_id]]&.delete_if { |v| v[:id] == current_user.id }
    
    # Broadcast updated viewers list
    broadcast_viewers
  end
  
  private
  
  def viewer_data
    {
      id: current_user.id,
      name: current_user.name,
      email: current_user.email
    }
  end
  
  def viewers
    @viewers ||= Rails.cache.fetch("note_viewers", expires_in: 24.hours) { {} }
  end
  
  def broadcast_viewers
    NotePresenceChannel.broadcast_to(
      @note,
      {
        viewers: viewers[params[:note_id]] || []
      }
    )
    
    Rails.cache.write("note_viewers", viewers, expires_in: 24.hours)
  end
end