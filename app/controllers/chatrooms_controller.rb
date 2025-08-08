class ChatroomsController < ApplicationController

  def index
      @chatrooms = Chatroom.all
  end

  def show
  @chatroom = Chatroom.find(params[:id])
  @messages = @chatroom.messages.order(:created_at)
end

  def new
    @chatroom = Chatroom.new
  end

def create
  @chatroom = Chatroom.find(params[:chatroom_id])
  current_user = User.find(session[:user_id])
  @message = @chatroom.messages.build(message_params)
  @message.sender_user = current_user

  if @message.save
    redirect_to chatroom_path(@chatroom)
  else
    render "chatrooms/show", status: :unprocessable_entity
  end
end

  private

  def chatroom_params
    params.require(:chatroom).permit(:user_match_1, :user_match_2, :match_id)
  end
end