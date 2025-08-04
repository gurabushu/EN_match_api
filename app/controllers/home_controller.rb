class HomeController < ApplicationController
  
  def index
    @users = User.all
    @user = User.new
  end

  def logout
    sign_out(current_user)
    redirect_to root_path
  end

  
end
