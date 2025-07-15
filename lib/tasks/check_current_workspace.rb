# Check current workspace for user
user = User.find_by(email: 'thenaeun1@gmail.com')
if user
  puts "User found: #{user.email}"
  puts "Current workspace: #{user.current_workspace&.name}"
  puts "Is admin? #{user.workspace_admin?}"
  
  if user.current_workspace
    workspace = user.current_workspace
    puts "\nWorkspace details:"
    puts "- ID: #{workspace.id}"
    puts "- Name: #{workspace.name}"
    puts "- Subdomain: #{workspace.subdomain}"
    
    member = workspace.workspace_members.find_by(user: user)
    puts "- User role: #{member&.role}"
  end
  
  puts "\nAll workspaces for user:"
  user.workspaces.each do |ws|
    member = ws.workspace_members.find_by(user: user)
    puts "- #{ws.name} (role: #{member&.role})"
  end
else
  puts "User not found"
end