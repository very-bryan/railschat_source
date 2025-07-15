class AddCurrentWorkspaceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :current_workspace, null: true, foreign_key: { to_table: :workspaces }
  end
end
