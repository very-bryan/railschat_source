class AddWorkspaceToChannels < ActiveRecord::Migration[8.0]
  def change
    add_reference :channels, :workspace, null: true, foreign_key: true
  end
end
