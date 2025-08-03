class UsersController < ApplicationController
    before_action :authenticate_user!


    def show #ユーザーリストからの詳細情報
        @user = User.find(params[:id])
        @users = User.all
        
    end

    def update #エンジニア情報更新
        @user = current_user
        if @user.update(user_params)
            redirect_to @user, notice:"プロフィールを更新しました"
        else
            render :edit
        end
    end

     def edit
        @user = current_user
     end

     def destroy
        @user = User.find(params[:id])
        @user.destroy
        redirect_to users_path,notice:"情報を削除しました"
    end

    private

    def user_params
        params.require(:user).permit(:name. :skill, :description)
    end

end
