class Status < ApplicationRecord
  belongs_to :workspace
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/ }, allow_blank: true
  # validates :order, presence: true, uniqueness: { scope: :workflow_id }

  scope :ordered, -> { order(:position) }

  def next_status
    Status.where(workflow_id: workflow_id).where('order > ?', order).order(:order).first
  end

  def previous_status
    Status.where(workflow_id: workflow_id).where('order < ?', order).order(order: :desc).first
  end
end
