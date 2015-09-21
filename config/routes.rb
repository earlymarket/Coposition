Rails.application.routes.draw do

  devise_for :users
  root to: "welcome#index"

  resources :api, only: [:index]

  namespace :redbox do
    resources :checkins, only: [:index, :show, :create, :destroy] do
      collection do
        get :spoof
        post :create_spoofs
      end
    end
    resources :devices, only: [:index, :show, :new, :edit, :create]
  end

end
