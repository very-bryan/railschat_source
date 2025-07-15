namespace :notifications do
  desc "Sync unread notification counts for all users"
  task sync_counts: :environment do
    User.find_each do |user|
      actual_count = user.notifications.unread.count
      if user.unread_notifications_count != actual_count
        puts "Syncing #{user.email}: #{user.unread_notifications_count} -> #{actual_count}"
        user.update_column(:unread_notifications_count, actual_count)
      end
    end
    puts "✅ Notification counts synced!"
  end
end