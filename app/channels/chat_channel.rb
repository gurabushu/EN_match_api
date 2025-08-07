class ChatChannel < ApplicationCable::Channel
   def subscribed
    chatroom = Chatroom.find(params[:chatroom_id])
    stream_from "chatroom_#{chatroom.id}"
  end

  def unsubscribed
   
  end
end