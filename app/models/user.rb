class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 自分が送ったいいね
  has_many :given_likes, foreign_key: :liker_id, class_name: 'Like', dependent: :destroy
  has_many :liked_users, through: :given_likes, source: :liked

  # 自分がもらったいいね
  has_many :received_likes, foreign_key: :liked_id, class_name: 'Like', dependent: :destroy
  has_many :likers, through: :received_likes, source: :liker
  has_many :likes


end
