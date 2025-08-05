class Match < ApplicationRecord
  belongs_to :user1
  belongs_to :user2

  validates :user1_id, uniqueness: { scope: :user2_id } # 重複マッチング防止
  validates :user2_id, uniqueness: { scope: :user1_id } # 重複マッチング防止
end
