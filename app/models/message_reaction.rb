class MessageReaction < ApplicationRecord
  belongs_to :message
  belongs_to :user
  
  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: [:message_id, :emoji] }
  
  after_create_commit { broadcast_reaction_update }
  after_destroy_commit { broadcast_reaction_update }
  
  private
  
  def broadcast_reaction_update
    # Turbo Stream으로 리액션 업데이트 브로드캐스트
    ActionCable.server.broadcast(
      "channel_#{message.channel_id}_reactions",
      {
        message_id: message.id,
        reactions: message.reactions.includes(:user).group_by(&:emoji).transform_values { |reactions|
          {
            count: reactions.count,
            users: reactions.map { |r| { id: r.user.id, name: r.user.name } }
          }
        }
      }
    )
  end
end