class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :body
      t.references :category, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :notes }
      t.date :start_date
      t.date :due_date

      t.timestamps
    end
  end
end
