class AddForeignKeysToChatrooms < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :chatrooms, :users, column: :user_match_1_id
    add_foreign_key :chatrooms, :users, column: :user_match_2_id
  end
end