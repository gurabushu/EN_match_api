class AddSenderAndRecipientToMessages < ActiveRecord::Migration[6.1] # ←Railsのバージョンに合わせて
  def change
    add_column :messages, :sender_user_id, :bigint
    add_column :messages, :recipient_user_id, :bigint

    add_index :messages, :sender_user_id
    add_index :messages, :recipient_user_id
  end
end