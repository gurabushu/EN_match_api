class RemoveSenderAndRecipientFromMessages < ActiveRecord::Migration[6.1]
  def change
    remove_index :messages, name: "index_messages_on_sender_user_id"
    remove_index :messages, name: "index_messages_on_recipient_user_id"
    
    remove_column :messages, :sender_user_id
    remove_column :messages, :recipient_user_id
  end
end