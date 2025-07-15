class AddCounterCaches < ActiveRecord::Migration[8.0]
  def change
    # Add counter caches for better performance
    add_column :channels, :messages_count, :integer, default: 0
    add_column :channels, :channel_members_count, :integer, default: 0
    add_column :notes, :children_count, :integer, default: 0
    add_column :notes, :note_assignees_count, :integer, default: 0
    add_column :users, :notes_count, :integer, default: 0
    add_column :users, :messages_count, :integer, default: 0
    add_column :users, :notifications_count, :integer, default: 0
    add_column :users, :unread_notifications_count, :integer, default: 0
    
    # Add indexes for counter cache columns
    add_index :channels, :messages_count
    add_index :channels, :channel_members_count
    add_index :notes, :children_count
    add_index :notes, :note_assignees_count
    add_index :users, :notes_count
    add_index :users, :messages_count
    add_index :users, :notifications_count
    add_index :users, :unread_notifications_count
  end
end
