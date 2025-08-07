class HomeController < ApplicationController
  
  def index
    @users = User.all

     if params[:search].present?
      @users = @users.where("name LIKE ?", "%#{params[:search]}%")
    end

    if params[:skill].present?
      @users = @users.where("skill LIKE ?", "%#{params[:skill]}%")
    end
  end


  def logout
    sign_out(current_user)
    redirect_to root_path
  end


end
