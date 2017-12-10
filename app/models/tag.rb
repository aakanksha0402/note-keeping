class Tag < ApplicationRecord
  enum status: [:active, :inactive]

  # Associations
  has_many :note_tags
  has_many :notes, through: :note_tags

  # Validations
  validates :name, presence: true, :uniqueness => { :case_sensitive => false }

end
