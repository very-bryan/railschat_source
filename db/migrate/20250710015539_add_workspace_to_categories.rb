class AddWorkspaceToCategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :workspace, null: true, foreign_key: true
  end
end
