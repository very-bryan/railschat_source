class CreateChannelMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :channel_members do |t|
      t.references :channel, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
