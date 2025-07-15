class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.references :parent, null: true, foreign_key: { to_table: :categories }
      t.text :description
      t.string :color

      t.timestamps
    end
  end
end
