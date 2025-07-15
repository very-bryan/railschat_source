class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :notification_type, null: false
      t.boolean :read, default: false
      t.integer :priority, default: 1
      t.string :related_type
      t.bigint :related_id
      t.string :action_url

      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
    add_index :notifications, [:related_type, :related_id]
  end
end
