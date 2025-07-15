namespace :workspace do
  desc "Reset Super workspace and create sample data"
  task reset_super: :environment do
    workspace = Workspace.find_by(name: 'Super')
    
    if workspace
      puts "Found Super workspace (ID: #{workspace.id})"
      user = workspace.users.where.not(provider: 'sample').first
      
      if user
        puts "Found user: #{user.email}"
        
        # Clean up existing data
        puts "Cleaning up existing data..."
        Note.where(workspace: workspace).destroy_all
        Message.joins(:channel).where(channels: { workspace: workspace }).destroy_all
        Channel.where(workspace: workspace).destroy_all
        Category.where(workspace: workspace).destroy_all
        Status.where(workspace: workspace).destroy_all
        
        # Remove sample users
        User.where(provider: 'sample').joins(:workspace_members)
            .where(workspace_members: { workspace: workspace }).destroy_all
        
        puts "Cleanup complete"
        
        # Generate new sample data
        puts "Generating sample data..."
        begin
          require_relative '../../app/services/sample_data_generator'
          SampleDataGenerator.generate_for_workspace(workspace, user)
          puts "Sample data generated successfully!"
          
          # Check results
          puts "\nCreated data:"
          puts "- Categories: #{Category.where(workspace: workspace).count}"
          puts "- Statuses: #{Status.where(workspace: workspace).count}"
          puts "- Channels: #{Channel.where(workspace: workspace).count}"
          puts "- Sample Notes: #{Note.where(workspace: workspace, is_sample: true).count}"
          puts "- Sample Messages: #{Message.joins(:channel).where(channels: { workspace: workspace }, is_sample: true).count}"
        rescue => e
          puts "Error: #{e.message}"
          puts e.backtrace.first(10).join("\n")
        end
      else
        puts "No non-sample users found in workspace"
      end
    else
      puts "Super workspace not found"
    end
  end
end