class AddUserIdToLikes < ActiveRecord::Migration[8.0]
  def change
    add_reference :likes, :user, null: false, foreign_key: true

  end
end
