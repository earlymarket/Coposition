Rails.application.routes.draw do

  root to: "welcome#index"

  resources :checkins, only: [:index, :show]

end
