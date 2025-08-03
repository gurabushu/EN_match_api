Rails.application.routes.draw do

  root "home#index"

  
get "search", to: "search#index"  # これが search_path を生成
  # または
end
