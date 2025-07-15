class AddPositionToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :position, :integer
    add_index :notes, [:status_id, :position]
    
    # Set initial positions for existing notes
    Note.reset_column_information
    Status.find_each do |status|
      status.notes.order(:created_at).each_with_index do |note, index|
        note.update_column(:position, index)
      end
    end
  end
end
