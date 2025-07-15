class AddMissingNotificationPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :marketing_emails, :boolean, default: false
    add_column :users, :browser_notifications, :boolean, default: true
    add_column :users, :quiet_hours, :boolean, default: false
  end
end
