class Note < ApplicationRecord
  enum status: [:active, :deleted]

  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  has_many :note_users
  has_many :users, through: :note_users
  has_many :note_tags
  has_many :tags, through: :note_tags

  validates :body, :title, presence: true

  def formatted_title
    title || truncate(self.body, length: 10)
  end

  def all_tags
    self.tags.map(&:name).join(",")
  end

  def all_users_without_this_note
    user_ids = self.users.pluck(:id)
    user_ids << self.created_by_id
    @users = User.where.not(id: user_ids)
  end
end
