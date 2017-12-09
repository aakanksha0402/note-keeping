class NoteUser < ApplicationRecord
  belongs_to :note
  belongs_to :user
  belongs_to :shared_by, class_name: "User", foreign_key: "shared_by_id", optional: true

  validates_uniqueness_of :note_id, :scope => :user_id

  before_save :already_shared

  def already_shared
    note = self.note
    user = self.user
    if note.created_by == user
      errors.add(:base, "This note does need not be shared with this user") #created by sharing user
      throw(:abort)
    elsif user == self.shared_by
      errors.add(:base, "This note is already shared with you")
      throw(:abort)
    else
      if note.created_by == self.shared_by || note.note_users.find_by(user: self.shared_by).present?
        return self
      else
        errors.add(:base, "You cannot share this note")
        throw(:abort)
      end
    end
  end

  def delete_shared_notes
    to_be_deleted = NoteUser.where(shared_by: self.user).pluck(:id)
    puts to_be_deleted
  end

end
