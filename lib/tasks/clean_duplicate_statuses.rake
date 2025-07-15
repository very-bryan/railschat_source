namespace :cleanup do
  desc "Clean duplicate statuses in workspaces"
  task statuses: :environment do
    Workspace.all.each do |workspace|
      puts "\nWorkspace: #{workspace.name} (ID: #{workspace.id})"
      
      # Keep only these 4 statuses
      keep_statuses = ['Backlog', 'To Do', 'In Progress', 'Done']
      
      # Find statuses to keep
      statuses_to_keep = []
      keep_statuses.each_with_index do |name, index|
        status = Status.where(workspace: workspace, name: name).first
        if status
          status.update!(position: index)
          statuses_to_keep << status
          puts "  Keeping: #{status.name} (position: #{index})"
        end
      end
      
      # Delete all other statuses
      Status.where(workspace: workspace)
            .where.not(id: statuses_to_keep.map(&:id))
            .each do |status|
        puts "  Deleting: #{status.name}"
        
        # Move notes to 'Backlog' status before deleting
        backlog = statuses_to_keep.find { |s| s.name == 'Backlog' }
        if backlog
          Note.where(status: status).update_all(status_id: backlog.id)
        end
        
        status.destroy
      end
      
      # Create missing statuses
      keep_statuses.each_with_index do |name, index|
        unless Status.exists?(workspace: workspace, name: name)
          color = case name
                  when 'Backlog' then '#6B7280'
                  when 'To Do' then '#3B82F6'
                  when 'In Progress' then '#F59E0B'
                  when 'Done' then '#10B981'
                  end
          
          Status.create!(
            workspace: workspace,
            name: name,
            color: color,
            position: index
          )
          puts "  Created: #{name} (position: #{index})"
        end
      end
    end
    
    puts "\nCleanup complete!"
  end
end