class Note < ApplicationRecord
  belongs_to :category
  belongs_to :status
  belongs_to :user, counter_cache: true
  belongs_to :workspace
  belongs_to :parent, class_name: 'Note', optional: true, counter_cache: :children_count
  
  has_many :children, class_name: 'Note', foreign_key: 'parent_id', dependent: :destroy
  has_many :note_assignees, dependent: :destroy
  has_many :assignees, through: :note_assignees, source: :user
  has_many :messages, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  
  has_many_attached :attachments
  
  validates :title, presence: true
  validates :body, presence: true
  
  scope :root, -> { where(parent_id: nil) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_assignee, ->(user) { joins(:note_assignees).where(note_assignees: { user: user }) }
  scope :overdue, -> { where('due_date < ?', Date.current) }
  scope :due_today, -> { where(due_date: Date.current) }
  scope :due_this_week, -> { where(due_date: Date.current..Date.current.end_of_week) }
  scope :ordered_by_position, -> { order(:position) }
  
  before_create :set_position
  after_update :reorder_positions, if: :saved_change_to_status_id?
  
  def overdue?
    due_date && due_date < Date.current
  end
  
  def due_today?
    due_date == Date.current
  end
  
  def completion_percentage
    return 100 if children.empty?
    completed_children = children.joins(:status).where(statuses: { name: 'Done' })
    (completed_children.count.to_f / children.count * 100).round
  end
  
  private
  
  def set_position
    self.position = user.notes.where(status_id: status_id).maximum(:position).to_i + 1
  end
  
  def reorder_positions
    # Reorder positions in the old status
    if status_id_before_last_save
      old_status_notes = user.notes.where(status_id: status_id_before_last_save).ordered_by_position
      old_status_notes.each_with_index do |note, index|
        note.update_column(:position, index)
      end
    end
    
    # Set position in new status
    self.position = user.notes.where(status_id: status_id).maximum(:position).to_i + 1
    self.update_column(:position, position)
  end
end
