Rails.application.routes.draw do

  devise_for :users
  root to: "welcome#index"

  namespace :redbox do
    resources :checkins, only: [:index, :show]
    resources :connections, only: [:index, :show, :new, :create]
    resources :api, only: [:index]
  end

end
