Rails.application.routes.draw do
  root "home#index"  # トップページがhome#indexになっているか確認

  devise_for :users

  get 'logout', to: 'home#logout'

  resources :likes, only: [:create, :destroy ] # いいねのルーティング設定
  
  resources :users, only: [:index, :show, :edit, :update,] do #認証とは別のルート
    member do 
      get :img #ユーザーの画像を取得するためのルート
      get :matches #CRUD７つの処理以外のルート設定。マッチング管理
      post "like", to: "likes#create"
      delete "unlike", to: "likes#destroy"
    end
  end

  get "search", to: "search#index"  # これが search_path を生成
  get "account", to: "account#show", as: :account  # アカウント情報のルート設定


end
