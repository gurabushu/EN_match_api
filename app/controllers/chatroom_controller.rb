class ChatroomsController < ApplicationController

  def index
    @chatrooms = Chatroom.all
  end

  def show
    @chatroom = Chatroom.find(params[:id])
  end

  def new
    @chatroom = Chatroom.new
  end

  def create
    @chatroom = Chatroom.new(chatroom_params)
    @chatroom.room = Chatroom.maximum(:room).to_i + 1  # 自動でルーム番号をインクリメント

    if @chatroom.save
      redirect_to chatroom_path(@chatroom), notice: 'チャットルームが作成されました。'
    else
      render :new
    end
  end

  private

  def chatroom_params
    params.require(:chatroom).permit(:user_match_1, :user_match_2, :match_id)
  end
end