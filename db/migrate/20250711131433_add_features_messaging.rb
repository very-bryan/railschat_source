class AddFeaturesMessaging < ActiveRecord::Migration[8.0]
  def change
    # 메시지 스레드 기능
    add_column :messages, :parent_message_id, :integer
    add_index :messages, :parent_message_id
    
    # 메시지 고정 기능
    add_column :messages, :is_pinned, :boolean, default: false
    add_column :messages, :pinned_at, :datetime
    add_index :messages, [:channel_id, :is_pinned]
    
    # 메시지 저장 기능
    create_table :saved_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :message, null: false, foreign_key: true
      t.timestamps
    end
    add_index :saved_messages, [:user_id, :message_id], unique: true
    
    # 리액션 기능
    create_table :message_reactions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :emoji, null: false
      t.timestamps
    end
    add_index :message_reactions, [:message_id, :user_id, :emoji], unique: true
  end
end
