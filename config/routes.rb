  get 'ai_recommendations', to: 'users#ai_recommendations', as: :ai_recommendations
Rails.application.routes.draw do
  root "home#index"  # トップページがhome#indexになっているか確認
  devise_for :users
  mount ActionCable.server => '/cable'  # Action Cableのルーティング設定

  get 'logout', to: 'home#logout'
  post 'users/guest_sign_in', to: 'users#guest_sign_in'

  resources :likes, only: [:index, :create, :destroy ] do 
    collection do
      get :received # いいねをくれたユーザー一覧
    end
  end

  resources :matches do
    get 'compatibility', on: :member
  end

  resources :chatrooms, only: [:create, :index, :show] do
    resources :messages, only: [:create, :index]  # チャットルーム内のメッセージのルーティング設定
  end



  resources :users, only: [:index, :show, :edit, :update,] do #認証とは別のルート
    member do 
      get :img #ユーザーの画像を取得するためのルート
      get :matches #CRUD７つの処理以外のルート設定。マッチング管理
      post "like", to: "likes#create"
      delete "unlike", to: "likes#destroy"
    end
  end

  get "/search", to: "home#index"  # これが search_path を生成
  get "account", to: "account#show", as: :account  # アカウント情報のルート設定
  get "likes", to: "likes#index"  # いいね管理のルート設定
  get "matches", to: "matches#index"  # マッチング一覧のルート設定
  get 'likes/received', to: 'likes#received', as: 'likes_received'



end
