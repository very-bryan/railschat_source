class CreateChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :channels do |t|
      t.string :name
      t.text :description
      t.boolean :is_private
      t.integer :project_id

      t.timestamps
    end
  end
end
