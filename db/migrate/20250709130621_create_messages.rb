class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :channel, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :thread_root, null: true, foreign_key: { to_table: :messages }
      t.references :note, null: true, foreign_key: true

      t.timestamps
    end
  end
end
