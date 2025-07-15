# Check all workspaces
puts "All workspaces:"
Workspace.all.each do |w|
  puts "- ID: #{w.id}, Name: #{w.name}, Subdomain: #{w.subdomain}"
  puts "  Users: #{w.users.count}"
  puts "  Admin: #{w.users.joins(:workspace_members).where(workspace_members: { role: 'admin' }).first&.email}"
end