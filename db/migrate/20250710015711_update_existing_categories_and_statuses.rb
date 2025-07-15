class UpdateExistingCategoriesAndStatuses < ActiveRecord::Migration[8.0]
  def up
    # Get the first workspace or create a default one
    default_workspace = Workspace.first || Workspace.create!(
      name: 'Default Workspace',
      subdomain: 'default'
    )
    
    # Update categories without workspace
    Category.where(workspace_id: nil).update_all(workspace_id: default_workspace.id)
    
    # Update statuses without workspace
    Status.where(workspace_id: nil).update_all(workspace_id: default_workspace.id)
    
    # Now make workspace_id required
    change_column_null :categories, :workspace_id, false
    change_column_null :statuses, :workspace_id, false
  end
  
  def down
    change_column_null :categories, :workspace_id, true
    change_column_null :statuses, :workspace_id, true
  end
end