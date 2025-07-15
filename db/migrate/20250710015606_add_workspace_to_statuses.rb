class AddWorkspaceToStatuses < ActiveRecord::Migration[8.0]
  def change
    add_reference :statuses, :workspace, null: true, foreign_key: true
  end
end
