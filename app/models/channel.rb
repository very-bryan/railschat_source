class Channel < ApplicationRecord
  belongs_to :workspace
  has_many :channel_members, dependent: :destroy
  has_many :members, through: :channel_members, source: :user
  has_many :users, through: :channel_members, source: :user
  has_many :channel_favorites, dependent: :destroy
  has_many :favorited_by_users, through: :channel_favorites, source: :user
  has_many :messages, dependent: :destroy
  
  validates :name, presence: true, 
                   uniqueness: { scope: :workspace_id, message: "이미 존재하는 채널명입니다" },
                   format: { 
                     with: /\A[가-힣a-zA-Z0-9_,\s-]+\z/, 
                     message: "채널명은 한글, 영문, 숫자, 쉼표, 공백, -, _ 만 사용할 수 있습니다" 
                   },
                   length: { minimum: 2, maximum: 50, message: "채널명은 2-50자 사이여야 합니다" }
  validates :is_private, inclusion: { in: [true, false] }
  
  scope :public_channels, -> { where(is_private: false) }
  scope :private_channels, -> { where(is_private: true) }
  
  def add_member(user, role = 'member')
    channel_members.create(user: user, role: role)
  end
  
  def remove_member(user)
    channel_members.find_by(user: user)&.destroy
  end
  
  def member?(user)
    members.include?(user)
  end
  
  def unread_messages_count_for(user)
    messages.where.not(id: user.read_messages.where(channel_id: id).pluck(:id)).count
  end
  
  def favorited_by?(user)
    channel_favorites.exists?(user: user)
  end
end
