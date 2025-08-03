Rails.application.routes.draw do

  devise_for :users

  resources :user, only: [:show, :edit, :update] #認証とは別のルート

  root "home#index"

  get "search", to: "search#index"  # これが search_path を生成

end
