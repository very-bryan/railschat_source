class AddShareFieldsToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :shared_from_message_id, :integer
    add_column :messages, :shared_from_channel_id, :integer
    add_column :messages, :shared_by_user_id, :integer
    
    add_index :messages, :shared_from_message_id
    add_index :messages, :shared_from_channel_id
    add_index :messages, :shared_by_user_id
  end
end
