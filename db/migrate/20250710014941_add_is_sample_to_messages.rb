class AddIsSampleToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :is_sample, :boolean, default: false, null: false
  end
end
