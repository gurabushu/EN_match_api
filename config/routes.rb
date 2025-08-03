Rails.application.routes.draw do

  root "home#index"

  resources :users, only: [:new, :create, :edit, :update, :destroy, :show] # ユーザー関連のルートを定義

get "search", to: "search#index"  # これが search_path を生成

end
