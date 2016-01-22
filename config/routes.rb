Rails.application.routes.draw do

  root to: "welcome#index"

  # Specified routes

  get '/api', to: 'welcome#api'

  # Devise

  devise_for :users, controllers: { 
    registrations: 'users/devise/registrations',
    sessions: 'users/devise/sessions'
  }
  devise_for :developers, controllers:
   { registrations: 'developers/devise/registrations' }

  # API

  resources :api, only: [:index]

  namespace :api, path: '', constraints: {subdomain: 'api'}, defaults: {format: 'json'} do
    namespace :v1 do
      resource :uuid, only: [:show]
      resources :demo do
        collection do
          get :reset_approvals
          get :demo_user_approves_demo_dev
        end
      end
      resources :checkins, only: [:create]
      resources :users do
        resources :approvals, only: [:create, :index, :update], module: :users do
          collection do
            get :status
          end
        end
        resources :devices, only: [:index, :show, :update], module: :users do
          member do
            post 'switch_privilege_for_developer'
          end
          collection do
            post 'switch_all_privileges_for_developer'
          end
          resources :checkins, only: [:index, :create], module: :devices do
            collection do
              get :last
            end
          end
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
    resources :devices, except: [:update, :edit] do
      member do
        post 'set_delay'
        delete 'checkin'
        post 'switch_privilege_for_developer'
        put 'fog'
      end
      collection do
        post 'switch_all_privileges_for_developer'
        get 'add_current'
      end
      resources :checkins, only: [:show, :destroy]
    end
    resources :approvals, only: [:index, :new, :create] do
      member do
        post 'approve'
        post 'reject'
      end 
    end
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
