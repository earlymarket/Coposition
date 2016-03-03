Rails.application.routes.draw do

  root to: "welcome#index"

  # Specified routes

  get '/api', to: 'welcome#api'

  # Devise

  devise_for :users, controllers: {
    registrations: 'users/devise/registrations',
    sessions: 'users/devise/sessions'
  }
  devise_for :developers, controllers: {
    registrations: 'developers/devise/registrations',
    sessions: 'developers/devise/sessions'
  }

  # API

  namespace :api, path: '', constraints: {subdomain: 'api'}, defaults: {format: 'json'} do
    namespace :v1 do
      resource :uuid, only: [:show]
      resources :demo do
        collection do
          get :reset_approvals
          get :demo_user_approves_demo_dev
        end
      end
      resources :users do
        resources :approvals, only: [:create, :index, :update], module: :users do
          collection do
            get :status
          end
        end
        resources :checkins, only: [:index], module: :users do
          collection do
            get :last
          end
        end
        resources :requests, only: [:index], module: :users do
          collection do
            get :last
          end
        end
        resources :devices, only: [:index, :show, :update], module: :users do
          resources :checkins, only: [:index, :create] do
            collection do
              get :last
            end
          end
          resources :permissions, only: [:update]
          put '/permissions', to: 'permissions#update_all'
        end
      end
      namespace :mobile_app do
        resources :sessions, only: [:create, :destroy]
      end
    end
  end



  # Users

  resources :users, only: [:show], module: :users do
    resource :dashboard, only: [:show]
    resources :devices, except: [:edit] do
      resources :checkins, only: [:show, :create, :new, :update]
      delete '/checkins/', to: 'checkins#destroy_all'
      delete '/checkins/:id', to: 'checkins#destroy'
      resources :permissions, only: [:update]
    end
    resources :approvals, only: [:new, :create] do
      member do
        post 'approve'
        post 'reject'
      end
    end
    resources :friends, only: [:show] do
      member do
        get 'show_device'
        get 'show_checkin'
      end
    end
    get '/applications', to: 'approvals#applications'
    get '/friends', to: 'approvals#friends'
  end



  # Devs
  resources :developers, only: [:edit, :update]

  namespace :developers do
    resource :console, only: [:show]
    resources :approvals, only: [:index, :new, :create]
    # For cool API usage stats in the future
    resources :requests, only: [:index] do
      collection do
        put :pay
      end
    end
  end
end
