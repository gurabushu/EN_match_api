class AddForeignKeyToChatrooms < ActiveRecord::Migration[8.0]
  def change
     add_foreign_key :chatrooms, :matches
  end
end
