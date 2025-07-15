class AddIsSampleToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :is_sample, :boolean, default: false, null: false
  end
end
