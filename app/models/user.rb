class User < ApplicationRecord
  has_one_attached :avatar # ユーザーのアバター画像を添付
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 }
  validates :skill, presence:true,length: {maximum:30}

  # 自分が送ったいいね
  has_many :given_likes, class_name: "Like", foreign_key: "liker_id", dependent: :destroy

  # 自分が受け取ったいいね
  has_many :received_likes, class_name: "Like", foreign_key: "liked_id", dependent: :destroy
end