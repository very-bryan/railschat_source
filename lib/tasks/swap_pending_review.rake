namespace :workspace do
  desc "Swap positions of Pending and Review statuses"
  task swap_pending_review: :environment do
    puts "Swapping Pending and Review positions for all workspaces..."
    
    Workspace.find_each do |workspace|
      puts "\nProcessing workspace: #{workspace.name}"
      
      ActiveRecord::Base.transaction do
        # Find the statuses
        pending_status = Status.find_by(workspace: workspace, name: 'Pending')
        review_status = Status.find_by(workspace: workspace, name: 'Review')
        
        if pending_status && review_status
          # Swap positions
          pending_status.update!(position: 4)
          review_status.update!(position: 3)
          puts "  ✓ Swapped positions: Review(3), Pending(4)"
        else
          puts "  ⚠ Missing status - Pending: #{pending_status.present?}, Review: #{review_status.present?}"
        end
        
        # Verify final order
        final_statuses = Status.where(workspace: workspace)
                              .order(:position)
                              .pluck(:name, :position)
                              .map { |name, pos| "#{name}(#{pos})" }
        puts "  Final order: #{final_statuses.join(' → ')}"
      end
    end
    
    puts "\nSwap complete!"
  end
end