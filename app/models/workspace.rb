class Workspace < ApplicationRecord
  has_many :workspace_members, dependent: :destroy
  has_many :users, through: :workspace_members
  has_many :channels, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :statuses, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_one_attached :icon
  
  validates :name, presence: true,
            format: { with: /\A[a-z0-9\-]+\z/, message: "영문 소문자, 숫자, 하이픈(-)만 사용 가능합니다" },
            length: { minimum: 3, maximum: 30, message: "3-30자 사이여야 합니다" },
            uniqueness: { case_sensitive: false, message: "이미 사용 중인 이름입니다" }
  validates :subdomain, presence: true, uniqueness: true, 
            format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers and hyphens" }
  
  before_validation :generate_subdomain, on: :create
  
  def admin?(user)
    workspace_members.find_by(user: user)&.admin?
  end
  
  def member?(user)
    workspace_members.exists?(user: user)
  end
  
  private
  
  def generate_subdomain
    return if subdomain.present?
    
    # name이 이미 소문자, 숫자, 하이픈만 포함하므로 그대로 사용
    self.subdomain = name.downcase
  end
end
