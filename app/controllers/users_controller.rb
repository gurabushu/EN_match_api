  # AIでおすすめユーザー（高相性ユーザー）一覧
  def ai_recommendations
    @users = User.where.not(id: current_user.id)
    @recommendations = []
    @users.each do |user|
      result = GeminiService.analyze_compatibility(current_user, user)
      if result =~ /相性スコア: (\d+)点/
        score = $1.to_i
        @recommendations << { user: user, score: score, detail: result }
      end
    end
    # スコア順で降順ソートし、上位のみ表示（例: 60点以上に緩和）
    @recommendations.select! { |rec| rec[:score] >= 60 }
    @recommendations.sort_by! { |rec| -rec[:score] }
  end
class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:edit, :update, :destroy, :show]

    def index
        @users = User.all
        @user = current_user
    end 

    def show
         @user = User.find(params[:id])
    end

    def edit
        @user = User.find(params[:id])
        unless @user
            redirect_to users_path, alert: "ユーザーが見つかりません"
            return
        end
        
        if @user.guest_user?
            redirect_to @user, alert: "ゲストユーザーのプロフィールは編集できません"
        end
    end

    def update
        @user = User.find(params[:id])
        
        if @user.guest_user?
            redirect_to @user, alert: "ゲストユーザーのプロフィールは編集できません"
            return
        end
        
        if @user.update(user_params)
            redirect_to @user, notice:"プロフィールを更新しました"
        else
            render :edit
        end
    end

    def destroy
        @user = User.find(params[:id])
        
        if @user.guest_user?
            redirect_to users_path, alert: "ゲストユーザーは削除できません"
            return
        end
        
        @user.destroy
        redirect_to users_path,notice:"情報を削除しました"
    end

    def guest_sign_in
        user = User.guest
        sign_in user
        redirect_to root_path, notice: 'ゲストユーザーとしてログインしました'
    end


    private


    def user_params
        params.require(:user).permit(:name, :skill, :description, :age, :avatar, :github)
    end


end
