class Chatroom < ApplicationRecord

  belongs_to :match
  belongs_to :user_match_1, class_name: 'User'
  belongs_to :user_match_2, class_name: 'User'
end
