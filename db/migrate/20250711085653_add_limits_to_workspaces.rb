class AddLimitsToWorkspaces < ActiveRecord::Migration[8.0]
  def change
    add_column :workspaces, :max_members, :integer
    add_column :workspaces, :max_storage_mb, :integer
    add_column :workspaces, :is_active, :boolean, default: true, null: false
  end
end
