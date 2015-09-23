Rails.application.routes.draw do

  root to: "welcome#index"

  
  devise_for :users
  devise_for :developers

  resources :api, only: [:index]

  resource :console, only: [:show]

  namespace :redbox do
    resources :checkins, only: [:index, :show, :create, :destroy] do
      collection do
        get :spoof
        post :create_spoofs
      end
    end
    resources :devices, only: [:index, :show, :new, :edit, :create, :destroy]
  end

end
