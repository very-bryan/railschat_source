class CreateMessageMentions < ActiveRecord::Migration[8.0]
  def change
    create_table :message_mentions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :message_mentions, [:message_id, :user_id], unique: true
  end
end
