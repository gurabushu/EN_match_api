class Message < ApplicationRecord
  belongs_to :chatroom
  belongs_to :sender_user, class_name: "User", foreign_key: "sender_user_id"
  belongs_to :recipient_user, class_name: "User", foreign_key: "recipient_user_id"

  # 自分側のユーザー名を返す
  def user_name_for(current_user)
    (sender_user == current_user ? sender_user : recipient_user)&.name || "未設定ユーザー"
  end

  # 相手側のユーザー名を返す
  def partner_name_for(current_user)
    (sender_user == current_user ? recipient_user : sender_user)&.name || "相手不明"
  end
end