class AddPermissionToNoteUser < ActiveRecord::Migration[5.0]
  def change
    enable_extension "hstore"
    add_column :note_users, :permissions, :hstore, null: false, default: {}
  end
end
