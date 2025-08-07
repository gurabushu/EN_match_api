class UpdateMessageUserColumns < ActiveRecord::Migration[6.1]
  def change
    # user_id を削除
    remove_column :messages, :user_id, :integer

    # sender_user_id と recipient_user_id を追加
    add_reference :messages, :sender_user, foreign_key: { to_table: :users }
    add_reference :messages, :recipient_user, foreign_key: { to_table: :users }
  end
end