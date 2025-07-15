class CreateStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :statuses do |t|
      t.string :name
      t.string :color
      t.integer :order
      t.integer :workflow_id

      t.timestamps
    end
  end
end
