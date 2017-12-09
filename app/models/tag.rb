class Tag < ApplicationRecord

  enum status: [:active, :inactive]
  has_many :note_tags
  has_many :notes, through: :note_tags

  validates :name, presence: true, :uniqueness => { :case_sensitive => false }
end
