namespace :channels do
  desc "Diagnose channel membership issues"
  task diagnose: :environment do
    puts "=== Channel Membership Diagnostics ==="
    puts ""
    
    # Check for channels without any members
    channels_without_members = Channel.left_joins(:channel_members).where(channel_members: { id: nil })
    if channels_without_members.any?
      puts "⚠️  Channels without any members:"
      channels_without_members.each do |channel|
        puts "   - #{channel.name} (ID: #{channel.id}, Workspace: #{channel.workspace.name})"
      end
      puts ""
    else
      puts "✅ All channels have at least one member"
      puts ""
    end
    
    # Check for users without access to any channels
    users_without_channels = User.left_joins(:channel_members).where(channel_members: { id: nil })
    if users_without_channels.any?
      puts "⚠️  Users without access to any channels:"
      users_without_channels.each do |user|
        puts "   - #{user.name || user.email} (ID: #{user.id})"
      end
      puts ""
    else
      puts "✅ All users have access to at least one channel"
      puts ""
    end
    
    # Show channel membership summary
    puts "📊 Channel Membership Summary:"
    Channel.includes(:channel_members, :workspace).find_each do |channel|
      member_count = channel.channel_members.count
      admin_count = channel.channel_members.where(role: 'admin').count
      puts "   - #{channel.name} (Workspace: #{channel.workspace.name}): #{member_count} members (#{admin_count} admins)"
    end
    puts ""
    
    # Check for duplicate memberships
    duplicates = ChannelMember.group(:channel_id, :user_id).having('COUNT(*) > 1').count
    if duplicates.any?
      puts "⚠️  Duplicate channel memberships found:"
      duplicates.each do |(channel_id, user_id), count|
        channel = Channel.find(channel_id)
        user = User.find(user_id)
        puts "   - User: #{user.name || user.email}, Channel: #{channel.name}, Count: #{count}"
      end
      puts ""
    else
      puts "✅ No duplicate channel memberships found"
      puts ""
    end
  end
  
  desc "Add user to channel"
  task :add_user, [:user_email, :channel_id] => :environment do |t, args|
    user = User.find_by(email: args[:user_email])
    channel = Channel.find_by(id: args[:channel_id])
    
    if user.nil?
      puts "❌ User not found: #{args[:user_email]}"
      exit
    end
    
    if channel.nil?
      puts "❌ Channel not found: #{args[:channel_id]}"
      exit
    end
    
    if channel.member?(user)
      puts "ℹ️  User #{user.email} is already a member of channel '#{channel.name}'"
    else
      member = channel.add_member(user, 'member')
      if member.persisted?
        puts "✅ Added #{user.email} to channel '#{channel.name}' as member"
      else
        puts "❌ Failed to add user: #{member.errors.full_messages.join(', ')}"
      end
    end
  end
  
  desc "Create default channel for workspace and add all users"
  task :create_default, [:workspace_id] => :environment do |t, args|
    workspace = Workspace.find_by(id: args[:workspace_id])
    
    if workspace.nil?
      puts "❌ Workspace not found: #{args[:workspace_id]}"
      puts "Available workspaces:"
      Workspace.all.each do |ws|
        puts "   - #{ws.name} (ID: #{ws.id})"
      end
      exit
    end
    
    # Create general channel if it doesn't exist
    channel = workspace.channels.find_or_create_by(name: "general") do |ch|
      ch.description = "General discussion channel"
      ch.is_private = false
    end
    
    if channel.persisted?
      puts "✅ Channel 'general' exists in workspace '#{workspace.name}'"
      
      # Add all workspace users to the channel
      workspace.users.each do |user|
        if channel.member?(user)
          puts "   - #{user.email} is already a member"
        else
          role = workspace.workspace_members.find_by(user: user)&.role == 'owner' ? 'admin' : 'member'
          member = channel.add_member(user, role)
          if member.persisted?
            puts "   ✅ Added #{user.email} as #{role}"
          else
            puts "   ❌ Failed to add #{user.email}: #{member.errors.full_messages.join(', ')}"
          end
        end
      end
    else
      puts "❌ Failed to create channel: #{channel.errors.full_messages.join(', ')}"
    end
  end
  
  desc "Fix orphaned channels (channels without admins)"
  task fix_orphaned: :environment do
    puts "🔧 Fixing orphaned channels..."
    
    Channel.includes(:channel_members).find_each do |channel|
      admin_count = channel.channel_members.where(role: 'admin').count
      
      if admin_count == 0 && channel.channel_members.any?
        # Make the first member an admin
        first_member = channel.channel_members.first
        first_member.update(role: 'admin')
        puts "   ✅ Made #{first_member.user.email} admin of '#{channel.name}'"
      end
    end
    
    puts "✅ Done!"
  end
end