Rails.application.routes.draw do

  root to: "welcome#index"

  
  devise_for :users, controllers:
   { registrations: 'users/devise/registrations' }
  devise_for :developers, controllers:
   { registrations: 'developers/devise/registrations' }

  resources :api, only: [:index]


  namespace :users do
    resource :dashboard, only: [:show]
    resources :approvals, only: [:index] do
      member do
        post "approve"
        post "reject"
      end
    end
  end

  namespace :developers do
    resource :console, only: [:show]
    resources :approvals, only: [:index, :new, :create]
  end

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
