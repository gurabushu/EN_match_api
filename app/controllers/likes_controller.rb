class LikesController < ApplicationController


 def likes_count
  user = User.find(params[:user_id])
  likes_count = Like.where(liked_id: user.id).count
  render json: { likes_count: likes_count }
end

 def destroy
  like = Like.find(params[:id])
  if like.liker == current_user
    like.destroy
    redirect_to root_path, notice: "いいねを取り消しました"
  else
    redirect_to root_path, alert: "自分のいいね以外は削除できません"
  end
end

  def new
    @like = Like.new
  end

def create
  @like = Like.new(
    liker_id: current_user.id,
    liked_id: params[:liked_id]
  )

  if @like.save
    redirect_to root_path, notice: "いいねしました"
  else
    redirect_to root_path, alert: "いいねに失敗しました"
  end
end

end
