class HomeController < ApplicationController
  
  def index
    @users = User.all
    @user = current_user ? User.where.not(id: current_user.id) : User.all  # 自分以外のユーザー

    if params[:search].present?
      @users = @users.where("name LIKE ?", "%#{params[:search]}%")
    end

    if params[:skill].present?
      @users = @users.where("skill LIKE ?", "%#{params[:skill]}%")
    end

    @users = @users.limit(3)
  end

  def show
    @user = User.find(params[:id])
  end

  def logout
    sign_out(current_user)
    redirect_to root_path
  end


end
