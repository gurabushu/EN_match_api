class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:edit, :update, :destroy, :show]

    def index
        @users = User.all
        @user = current_user
    end 

    def show
         @user = current_user
    end

    def edit
        @user = User.find(params[:id])
        unless @user
            redirect_to users_path, alert: "ユーザーが見つかりません"
        end
    end

    def update
        @user = User.find(params[:id])
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
        params.require(:user).permit(:name, :skill, :description, :age, :avatar, :github)
    end


end
