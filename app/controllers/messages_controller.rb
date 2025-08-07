# app/controllers/messages_controller.rb

class MessagesController < ApplicationController
  def create
    @chatroom = Chatroom.find(params[:chatroom_id])
    @message = @chatroom.messages.build(message_params)
    @message.sender_user = current_user

    if @message.save
      redirect_to chatroom_path(@chatroom)
    else
      @messages = @chatroom.messages.order(:created_at)
      render "chatrooms/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :recipient_user_id)
  end
end