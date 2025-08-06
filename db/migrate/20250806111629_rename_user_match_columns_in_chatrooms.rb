class RenameUserMatchColumnsInChatrooms < ActiveRecord::Migration[8.0]
  def change
      rename_column :chatrooms, :user_match_1, :user_match_1_id
    rename_column :chatrooms, :user_match_2, :user_match_2_id
  end
end
