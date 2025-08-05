class CreateChatrooms < ActiveRecord::Migration[8.0]
  def change
    create_table :chatrooms do |t|
      t.integer :room
      t.integer :user_match_1
      t.integer :user_match_2

      t.timestamps
    end
  end
end
