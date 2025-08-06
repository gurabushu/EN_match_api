class Match < ApplicationRecord
  belongs_to :user1, class_name: "User", foreign_key: "user1_id"
  belongs_to :user2, class_name: "User", foreign_key: "user2_id"

  has_one :chatroom, dependent: :destroy

  after_commit :create_chatroom, on: :create

  private

  def create_chatroom
    Chatroom.create!(
      match: self,
      room: Chatroom.maximum(:room).to_i + 1,
      user_match_1: self.user1,
      user_match_2: self.user2
    )
  end
end