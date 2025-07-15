class AddWorkspaceToNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :workspace, null: true, foreign_key: true
  end
end
