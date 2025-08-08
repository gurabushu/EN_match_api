require 'securerandom'

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

  def self.guest
    # 既存のゲストユーザーを検索、なければ作成
    guest_user = find_by(email: 'guest@example.com')
    
    unless guest_user
      guest_user = create!(
        name: 'ゲストユーザー',
        email: 'guest@example.com',
        password: SecureRandom.urlsafe_base64,
        description: 'これはゲストユーザーのアカウントです。お試しでアプリを利用できます。',
        skill: 'Ruby on Rails, JavaScript',
        github: 'https://github.com/guest-user'
      )
    end
    
    guest_user
  end

  def guest_user?
    email == 'guest@example.com'
  end
end