class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params[:chatroom_id].present?
      begin
        chatroom = Chatroom.find(params[:chatroom_id])
        stream_from "chatroom_#{chatroom.id}"
      rescue ActiveRecord::RecordNotFound
        reject
      end
    else
      reject
    end
  end

  def unsubscribed
   
  end
end