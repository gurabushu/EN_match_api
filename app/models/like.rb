class Like < ApplicationRecord
  belongs_to :liker, class_name: "User", foreign_key: "liker_id"
  belongs_to :liked_user, class_name: "User", foreign_key: "liked_id"

  validates :liker_id, uniqueness: { scope: :liked_id, message: "はすでにこのユーザーにいいねしています" }


end