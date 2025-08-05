class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 自分がいいねしたユーザー一覧
  has_many :given_likes, class_name: 'Like', foreign_key: 'liker_id', dependent: :destroy
  has_many :like_users, through: :given_likes, source: :liked

  # 自分がいいねされた一覧（必要であれば）
  has_many :received_likes, class_name: 'Like', foreign_key: 'liked_id', dependent: :destroy
  has_many :likers, through: :received_likes, source: :liker



end
