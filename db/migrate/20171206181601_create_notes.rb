class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.text :body
      t.integer :status, default: 0
      t.references :created_by

      t.timestamps
    end
  end
end
