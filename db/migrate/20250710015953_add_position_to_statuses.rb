class AddPositionToStatuses < ActiveRecord::Migration[8.0]
  def change
    add_column :statuses, :position, :integer, default: 0
    add_index :statuses, [:workspace_id, :position]
  end
end
