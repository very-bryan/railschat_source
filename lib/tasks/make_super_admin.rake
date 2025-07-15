namespace :admin do
  desc "Make a user super admin"
  task :make_super => :environment do
    email = ENV['EMAIL'] || User.first&.email
    
    if email.blank?
      puts "No users found in the database"
      exit
    end
    
    user = User.find_by(email: email)
    
    if user.nil?
      puts "User with email #{email} not found"
      exit
    end
    
    user.update(super_admin: true)
    puts "✅ #{user.email} is now a super admin!"
    puts "Access super admin panel at: /super_admin"
  end
end