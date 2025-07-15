class ChannelMember < ApplicationRecord
  belongs_to :channel, counter_cache: :channel_members_count
  belongs_to :user
  
  validates :channel_id, uniqueness: { scope: :user_id }
  validates :role, inclusion: { in: %w[admin member] }
end
