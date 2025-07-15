namespace :workspace do
  desc "Update all workspaces with default statuses"
  task update_statuses: :environment do
    puts "Updating all workspaces with default statuses..."
    
    require_relative '../../app/services/workspace_setup_service'
    
    WorkspaceSetupService.update_all_workspaces
    
    puts "\nStatus summary:"
    Workspace.all.each do |workspace|
      statuses = Status.where(workspace: workspace).order(:position).pluck(:name)
      puts "#{workspace.name}: #{statuses.join(', ')}"
    end
    
    puts "\nUpdate complete!"
  end
  
  desc "Setup default data for a specific workspace"
  task :setup, [:workspace_name] => :environment do |task, args|
    workspace = Workspace.find_by(name: args[:workspace_name])
    
    if workspace
      user = workspace.users.where.not(provider: 'sample').first
      if user
        WorkspaceSetupService.setup_workspace(workspace, user)
        puts "Setup completed for #{workspace.name}"
      else
        puts "No non-sample users found in workspace"
      end
    else
      puts "Workspace '#{args[:workspace_name]}' not found"
    end
  end
end