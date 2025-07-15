workspace = Workspace.find_by(name: 'Super')
if workspace
  puts "Testing sample user creation for workspace ID: #{workspace.id}"
  
  user = User.new(
    email: "sample_kim_#{workspace.id}@example.com",
    password: SecureRandom.hex(10),
    first_name: "지민",
    last_name: "김",
    current_workspace: workspace,
    provider: 'sample',
    uid: "sample_kim_#{workspace.id}"
  )
  
  if user.valid?
    puts "User is valid"
    user.save!
    puts "User created successfully"
  else
    puts "User is invalid:"
    puts user.errors.full_messages
  end
end