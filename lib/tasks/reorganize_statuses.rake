namespace :workspace do
  desc "Reorganize statuses to 6 stages: Backlog, To Do, In Progress, Pending, Review, Done"
  task reorganize_statuses: :environment do
    puts "Reorganizing statuses for all workspaces..."
    
    Workspace.find_each do |workspace|
      puts "\nProcessing workspace: #{workspace.name}"
      
      ActiveRecord::Base.transaction do
        # Find or create Review status
        review_status = Status.find_or_create_by!(
          workspace: workspace,
          name: 'Review'
        ) do |status|
          status.color = '#8B5CF6'
          status.position = 4
        end
        puts "  ✓ Review status ready"
        
        # Move notes from Doing to In Progress
        doing_status = Status.find_by(workspace: workspace, name: 'Doing')
        if doing_status
          in_progress = Status.find_by(workspace: workspace, name: 'In Progress')
          if in_progress
            Note.where(status: doing_status).update_all(status_id: in_progress.id)
            puts "  ✓ Moved #{doing_status.notes.count} notes from Doing to In Progress"
          end
          doing_status.destroy
          puts "  ✓ Removed Doing status"
        end
        
        # Ensure all statuses have correct positions
        status_order = ['Backlog', 'To Do', 'In Progress', 'Pending', 'Review', 'Done']
        status_order.each_with_index do |name, index|
          status = Status.find_by(workspace: workspace, name: name)
          if status && status.position != index
            status.update!(position: index)
            puts "  ✓ Updated position for #{name}: #{index}"
          end
        end
        
        # Remove any extra statuses not in our list
        extra_statuses = Status.where(workspace: workspace)
                              .where.not(name: status_order)
        if extra_statuses.any?
          extra_statuses.each do |status|
            # Move notes to Backlog before deleting
            backlog = Status.find_by(workspace: workspace, name: 'Backlog')
            Note.where(status: status).update_all(status_id: backlog.id) if backlog
            puts "  ✓ Removing extra status: #{status.name}"
            status.destroy
          end
        end
      end
      
      # Display final status list
      final_statuses = Status.where(workspace: workspace).order(:position).pluck(:name)
      puts "  Final statuses: #{final_statuses.join(' → ')}"
    end
    
    puts "\nReorganization complete!"
  end
end