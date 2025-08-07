class Chatroom < ApplicationRecord

  belongs_to :match
  belongs_to :user_match_1, class_name: 'User'
  belongs_to :user_match_2, class_name: 'User'

  has_many :messages, dependent: :destroy

    def partner_user(current_user)
    user1 == current_user ? user2 : user1
  end
end
