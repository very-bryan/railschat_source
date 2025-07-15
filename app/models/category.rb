class Category < ApplicationRecord
  belongs_to :workspace
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/ }, allow_blank: true

  scope :root, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:name) }

  def full_path
    path = []
    current = self
    while current
      path.unshift(current.name)
      current = current.parent
    end
    path.join(' > ')
  end
end
