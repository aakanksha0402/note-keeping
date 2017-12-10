class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Validations
  has_many :created_notes, class_name: "Note", foreign_key: 'created_by_id'
  has_many :note_users
  has_many :notes, through: :note_users
  has_many :shared_notes, foreign_key: "shared_by_id", class_name: "NoteUser"
  has_many :created_note_tags, foreign_key: "added_by_id", class_name: "NoteTag"

  scope :all_except, ->(user_id) { where.not(id: user_id) }

  def to_s
    email
  end
end
