class CreateNoteUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :note_users do |t|
      t.references :note, foreign_key: true
      t.references :user, foreign_key: true
      t.references :shared_by
      
      t.timestamps
    end
  end
end
