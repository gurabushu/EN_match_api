class LikesController < ApplicationController

  def index
   @likes = Like.where(liker_id: current_user.id).includes(:liked_user)
  end

  def received
    @likes_received = Like.where(liked_id: current_user.id).includes(:liker)
  end

  def show
    @like = User.find(params[:id])
  end
  
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
  @like = current_user.given_likes.build(liked_id: params[:liked_id])
  
  if @like.save
    # 相手も自分を「いいね」していたらマッチング成立
    if Like.exists?(liker_id: @like.liked_id, liked_id: current_user.id)
      Match.create(user1_id: current_user.id, user2_id: @like.liked_id, status: true)
    end

    redirect_to root_path, notice: "いいねしました！"
  else
    render :new
  end
end

private
def like_params
  params.permit(:liked_id) 
end

end
