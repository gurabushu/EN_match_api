class UsersController < ApplicationController
    def new #新規登録画面
        @user = User.new
    end

    def show #ユーザーリストからの詳細情報
        @user = User.find(params[:id])
        @users = User.all
        
    end

    def create #エンジニア情報登録
        @user = User.new(user_params)
        if @user.save
            redirect_to @user, notice: "登録完了"
        else
            render :new
        end
     end

     def edit
        @user = User.find(params[:id])
     end

     def destroy
        @user = User.find(params[:id])
        @user.destroy
        redirect_to users_path,notice:"情報を削除しました"
    end

    private


end
