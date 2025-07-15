class NoteAssignee < ApplicationRecord
  belongs_to :note, counter_cache: :note_assignees_count
  belongs_to :user
  
  validates :note_id, uniqueness: { scope: :user_id }
end
