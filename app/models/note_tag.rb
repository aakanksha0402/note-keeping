class NoteTag < ApplicationRecord

  # Associations
  belongs_to :note
  belongs_to :tag
  belongs_to :added_by, class_name: "User", foreign_key: "added_by_id"

  # Validations
  validates_uniqueness_of :note_id, :scope => :tag_id
end
