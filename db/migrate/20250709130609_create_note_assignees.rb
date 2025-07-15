class CreateNoteAssignees < ActiveRecord::Migration[8.0]
  def change
    create_table :note_assignees do |t|
      t.references :note, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
