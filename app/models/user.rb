class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :notes, dependent: :destroy
  has_many :note_assignees, dependent: :destroy
  has_many :assigned_notes, through: :note_assignees, source: :note
  has_many :channel_members, dependent: :destroy
  has_many :channels, through: :channel_members
  has_many :channel_favorites, dependent: :destroy
  has_many :favorite_channels, through: :channel_favorites, source: :channel
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :saved_messages, dependent: :destroy
  has_many :bookmarked_messages, through: :saved_messages, source: :message
  has_many :message_reactions, dependent: :destroy
  has_many :message_reads, dependent: :destroy
  has_many :read_messages, through: :message_reads, source: :message
  
  has_many :workspace_members, dependent: :destroy
  has_many :workspaces, through: :workspace_members
  belongs_to :current_workspace, class_name: 'Workspace', optional: true

  # Active Storage
  has_one_attached :avatar

  validates :email, presence: true, uniqueness: true
  
  def full_name
    "#{first_name} #{last_name}".strip
  end
  
  def name
    full_name.presence || email.split('@').first
  end
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.google_avatar_url = auth.info.image
    end
  end
  
  def avatar_url
    if avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: true)
    else
      google_avatar_url || gravatar_url
    end
  end
  
  def workspace_admin?(workspace = nil)
    workspace ||= current_workspace
    return false unless workspace
    
    workspace_member = workspace_members.find_by(workspace: workspace)
    workspace_member&.admin? || false
  end
  
  def super_admin?
    super_admin == true
  end
  
  private
  
  def gravatar_url
    hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{hash}?d=mp&s=200"
  end
end
