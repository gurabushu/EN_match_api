class MatchesController < ApplicationController
  
def index
  @users = User.where.not(id: current_user.id)
  @matches = Match.where(status: true).includes(:user1, :user2)
end

def create
  liked_id = params[:liked_id]
  @like = current_user.given_likes.build(liked_id: liked_id)

  if @like.save
    if Like.exists?(liker_id: liked_id, liked_id: current_user.id)
      Match.create!(user1_id: current_user.id, user2_id: liked_id, status: true)
    end
  end

  redirect_to root_path
end

def destroy
  @matches = Match.find(params[:id])
  if @matches.destroy
    flash[:notice] = "マッチングを解除しました。"
  else
    flash[:alert] = "マッチングの解除に失敗しました。"
  end
  redirect_to matches_path
end

  def show
    @match = Match.find(params[:id])
    @ai_result = AiMatchService.analyze_compatibility(@match.user1, @match.user2)
  end

def compatibility
  match = Match.find_by(id: params[:id])
  if match.nil?
    redirect_to matches_path, alert: "対象マッチングが存在しません。" and return
  end

  @user1 = match.user1
  @user2 = current_user

  @compatibility_result = GeminiService.analyze_compatibility(@user1, @user2)
  Rails.logger.debug "Gemini診断結果: #{@compatibility_result.inspect}"
end

end