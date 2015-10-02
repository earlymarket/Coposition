Rails.application.routes.draw do

  root to: "welcome#index"

  
  # Devise

  devise_for :users, controllers:
   { registrations: 'users/devise/registrations' }
  devise_for :developers, controllers:
   { registrations: 'developers/devise/registrations' }



  # API

  resources :api, only: [:index]

  namespace :api, path: '', constraints: {subdomain: 'api'}, defaults: {format: 'json'} do
    namespace :v1 do
      resources :checkins, only: [:create]
      resources :users do
        resources :devices, module: :users do
          collection do
            get :run
            get :stop
          end
        end
      end
    end
  end



  # Users

  resources :users, only: [:show], module: :users do
    resource :dashboard, only: [:show]
    resources :approvals, only: [:index] do
      member do
        post "approve"
        post "reject"
      end
    end
  end



  # Devs

  namespace :developers do
    resource :console, only: [:show]
    resources :approvals, only: [:index, :new, :create]
  end





  # Redbox

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
