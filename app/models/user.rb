class User < ApplicationRecord
  has_one_attached :avatar # ユーザーのアバター画像を添付
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 }

  has_many :given_likes, class_name: "Like", foreign_key: "liker_id", dependent: :destroy
  has_many :received_likes, class_name: "Like", foreign_key: "liked_id", dependent: :destroy
  has_many :chatrooms_as_user1, class_name: "Chatroom", foreign_key: "user_match_1_id", dependent: :destroy
  has_many :chatrooms_as_user2, class_name: "Chatroom", foreign_key: "user_match_2_id", dependent: :destroy
  has_many :messages, dependent: :destroy

has_many :likes, foreign_key: :liker_id
has_many :liked_users, through: :likes, source: :liked_user
has_many :likes_received, class_name: "Like", foreign_key: :liked_id
has_many :likers, through: :likes_received, source: :user
end