class ChatroomController < ApplicationController

  def create

  end

  def index
    @chatrooms = Chatroom.all
  end