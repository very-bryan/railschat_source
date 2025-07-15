class UpdateExistingNotesWithWorkspace < ActiveRecord::Migration[8.0]
  def up
    # First, check if there are any notes without workspace
    notes_without_workspace = Note.where(workspace_id: nil)
    
    if notes_without_workspace.exists?
      # Create a default workspace if none exists
      default_workspace = Workspace.first || Workspace.create!(
        name: 'Default Workspace',
        subdomain: 'default'
      )
      
      # Update all notes to have this workspace
      notes_without_workspace.update_all(workspace_id: default_workspace.id)
    end
    
    # Now make workspace_id required for future records
    change_column_null :notes, :workspace_id, false
  end
  
  def down
    change_column_null :notes, :workspace_id, true
  end
end
