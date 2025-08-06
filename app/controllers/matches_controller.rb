class MatchesController < ApplicationController

  def index
    @matches = Match.where(status: true).includes(:user1, :user2, :chatroom)
  end

  def create
    @likes = current_user.given_likes.build(liked_id: params[:liked_id])
    Match.create!(user1_id: current_user.id, user2_id: @likes.liked_id, status: true)

    if @likes.save
      if Like.exists?(liker_id: @likes.liked_id, liked_id: current_user.id)
        Match.create!(user1_id: current_user.id, user2_id: @likes.liked_id, status: true)
        # create! により after_create が発火し、chatroom も作成される
      end
    end
  end

end