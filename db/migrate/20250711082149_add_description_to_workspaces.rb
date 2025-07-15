class AddDescriptionToWorkspaces < ActiveRecord::Migration[8.0]
  def change
    add_column :workspaces, :description, :text
  end
end
