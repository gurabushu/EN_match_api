class SearchController < ApplicationController
    def index
        @users = User.all
        if params[:search].present?
            @users = @users.where("skill LIKE ?", "%#{params[:search]}%")
        end
        if params[:search].present?
            @users = @users.where(
                "name ILIKE ? OR skill ILIKE ? OR description ILIKE ?",
                "%#{params[:search]}%",
                "%#{params[:search]}%",
                "%#{params[:search]}%"
            )
        end
    end

end
