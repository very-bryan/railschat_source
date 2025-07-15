namespace :sample do
  desc "Check sample data for a workspace"
  task check: :environment do
    workspace = Workspace.find_by(name: 'Super')
    
    if workspace
      puts "Workspace: #{workspace.name} (ID: #{workspace.id})"
      puts "Sample Notes: #{Note.where(workspace: workspace, is_sample: true).count}"
      puts "Sample Messages: #{Message.joins(:channel).where(channels: { workspace: workspace }, is_sample: true).count}"
      puts "Sample Users: #{User.where(email: ["sample_kim_#{workspace.id}@example.com", "sample_lee_#{workspace.id}@example.com"]).count}"
      puts "Total Notes: #{Note.where(workspace: workspace).count}"
      puts "Categories: #{Category.where(workspace: workspace).pluck(:name).join(', ')}"
      puts "Statuses: #{Status.where(workspace: workspace).pluck(:name).join(', ')}"
      puts "Channels: #{Channel.where(workspace: workspace).pluck(:name).join(', ')}"
    else
      puts "Workspace 'Super' not found"
    end
  end
  
  desc "Generate sample data for a workspace"
  task generate: :environment do
    workspace = Workspace.find_by(name: 'Super')
    
    if workspace
      user = workspace.users.first
      if user
        begin
          require_relative '../../app/services/sample_data_generator'
          
          ActiveRecord::Base.transaction do
            generator = SampleDataGenerator.new(workspace, user)
            
            puts "Creating sample users..."
            generator.send(:create_sample_users)
            puts "✓ Sample users created"
            
            puts "Creating channels..."
            generator.send(:create_channels)
            puts "✓ Channels created"
            
            puts "Creating categories..."
            generator.send(:create_categories)
            puts "✓ Categories created"
            
            puts "Creating statuses..."
            generator.send(:create_statuses)
            puts "✓ Statuses created"
            
            puts "Creating notes..."
            generator.send(:create_notes)
            puts "✓ Notes created"
            
            puts "Creating messages..."
            generator.send(:create_messages)
            puts "✓ Messages created"
          end
          
          puts "Sample data generated successfully!"
        rescue ActiveRecord::RecordInvalid => e
          puts "Validation Error: #{e.record.errors.full_messages.join(', ')}"
          puts "Record: #{e.record.inspect}"
        rescue => e
          puts "Error: #{e.message}"
          puts e.backtrace.first(10).join("\n")
        end
      else
        puts "No users found in workspace"
      end
    else
      puts "Workspace 'Super' not found"
    end
  end
end