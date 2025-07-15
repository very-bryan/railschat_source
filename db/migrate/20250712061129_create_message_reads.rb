class CreateMessageReads < ActiveRecord::Migration[8.0]
  def change
    create_table :message_reads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :message, null: false, foreign_key: true
      t.datetime :read_at

      t.timestamps
    end
    
    # Add unique index to prevent duplicate reads
    add_index :message_reads, [:user_id, :message_id], unique: true
  end
end
