class RemoveLikedUserIdFromLikes < ActiveRecord::Migration[8.0]
  def change
    remove_column :likes, :liked_user_id, :integer
  end
end
