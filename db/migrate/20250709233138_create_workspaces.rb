class CreateWorkspaces < ActiveRecord::Migration[8.0]
  def change
    create_table :workspaces do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
    add_index :workspaces, :subdomain, unique: true
  end
end
