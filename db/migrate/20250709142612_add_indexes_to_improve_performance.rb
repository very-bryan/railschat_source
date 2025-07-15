class AddIndexesToImprovePerformance < ActiveRecord::Migration[8.0]
  def change
    # Notes table indexes - only add if they don't exist
    add_index :notes, :created_at unless index_exists?(:notes, :created_at)
    add_index :notes, :updated_at unless index_exists?(:notes, :updated_at)
    add_index :notes, :due_date unless index_exists?(:notes, :due_date)
    add_index :notes, [:user_id, :created_at] unless index_exists?(:notes, [:user_id, :created_at])
    add_index :notes, [:user_id, :status_id] unless index_exists?(:notes, [:user_id, :status_id])
    add_index :notes, [:user_id, :category_id] unless index_exists?(:notes, [:user_id, :category_id])
    
    # Messages table indexes
    add_index :messages, :created_at unless index_exists?(:messages, :created_at)
    add_index :messages, [:channel_id, :created_at] unless index_exists?(:messages, [:channel_id, :created_at])
    
    # Channels table indexes
    add_index :channels, :created_at unless index_exists?(:channels, :created_at)
    add_index :channels, :updated_at unless index_exists?(:channels, :updated_at)
    add_index :channels, :is_private unless index_exists?(:channels, :is_private)
    
    # Channel members table indexes
    add_index :channel_members, [:channel_id, :user_id], unique: true unless index_exists?(:channel_members, [:channel_id, :user_id])
    
    # Note assignees table indexes
    add_index :note_assignees, [:note_id, :user_id], unique: true unless index_exists?(:note_assignees, [:note_id, :user_id])
    
    # Notifications table indexes
    add_index :notifications, :created_at unless index_exists?(:notifications, :created_at)
    add_index :notifications, :read unless index_exists?(:notifications, :read)
    add_index :notifications, [:user_id, :read] unless index_exists?(:notifications, [:user_id, :read])
    add_index :notifications, [:user_id, :created_at] unless index_exists?(:notifications, [:user_id, :created_at])
    
    # Users table indexes
    add_index :users, :created_at unless index_exists?(:users, :created_at)
    add_index :users, :updated_at unless index_exists?(:users, :updated_at)
  end
end
