class AddSettingsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :timezone, :string, default: 'Asia/Seoul'
    add_column :users, :language, :string, default: 'ko'
    add_column :users, :theme, :string, default: 'light'
    add_column :users, :email_notifications, :boolean, default: true
    add_column :users, :push_notifications, :boolean, default: true
  end
end
