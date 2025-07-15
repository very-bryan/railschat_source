class WorkspaceMember < ApplicationRecord
  belongs_to :workspace
  belongs_to :user
  
  ROLES = %w[admin member].freeze
  
  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :workspace_id }
  
  before_validation :set_defaults
  
  def admin?
    role == 'admin'
  end
  
  def member?
    role == 'member'
  end
  
  private
  
  def set_defaults
    self.role ||= 'member'
    self.joined_at ||= Time.current
  end
end
