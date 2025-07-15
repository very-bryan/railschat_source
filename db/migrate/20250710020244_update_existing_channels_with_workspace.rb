class UpdateExistingChannelsWithWorkspace < ActiveRecord::Migration[8.0]
  def up
    # Get the first workspace or create a default one
    default_workspace = Workspace.first || Workspace.create!(
      name: 'Default Workspace',
      subdomain: 'default'
    )
    
    # Update channels without workspace
    Channel.where(workspace_id: nil).update_all(workspace_id: default_workspace.id)
    
    # Now make workspace_id required
    change_column_null :channels, :workspace_id, false
  end
  
  def down
    change_column_null :channels, :workspace_id, true
  end
end
