class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:edit, :update, :destroy, :show]

    def index
        @users = User.all
        @user = User.new
    end 

    def show
         @user = current_user
        if @user.nil?
            redirect_to root_path, alert: "ユーザーが見つかりません"
        else
            @user = User.find(params[:id])
        end
    end

    def update #エンジニア情報更新
        @user = current_user
        if @user.update(user_params)
            redirect_to @user, notice:"プロフィールを更新しました"
        else
            render :edit
        end
    end

     def destroy
        @user = User.find(params[:id])
        @user.destroy
        redirect_to users_path,notice:"情報を削除しました"
    end

    private

    def user_params
        params.require(:user).permit(:name, :skill, :description)
    end


end
