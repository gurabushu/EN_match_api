  # AIでおすすめユーザー（高相性ユーザー）一覧
  def ai_recommendations
    @users = User.where.not(id: current_user.id)
    Rails.logger.info "[AIおすすめ] 対象ユーザー数: #{@users.size}"
    @recommendations = []
    @users.each do |user|
      result = GeminiService.analyze_compatibility(current_user, user)
      if result =~ /相性スコア: (\d+)点/
        score = $1.to_i
        @recommendations << { user: user, score: score, detail: result }
      else
        Rails.logger.warn "[AIおすすめ] スコア抽出失敗: user_id=#{user.id}, result=#{result.inspect}"
      end
    end
    Rails.logger.info "[AIおすすめ] 推薦候補数(抽出前): #{@recommendations.size}"
    @recommendations.select! { |rec| rec[:score] >= 40 }
    Rails.logger.info "[AIおすすめ] 推薦候補数(40点以上): #{@recommendations.size}"
    @recommendations.sort_by! { |rec| -rec[:score] }
  end
class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:edit, :update, :destroy, :show, :ai_recommendations]

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
