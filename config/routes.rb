Rails.application.routes.draw do

  root to: "welcome#index"
  get '/reset_for_demo', to: 'welcome#reset_for_demo'

  # Devise

  devise_for :users, controllers:
   { registrations: 'users/devise/registrations' }
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
        resources :approvals, only: [:create], module: :users do
          collection do
            get :status
          end
        end
        resources :devices, only: [:index, :show], module: :users do
          resources :checkins, module: :devices do
            collection do
              get :last
            end
          end
        end
      end
    end
  end



  # Users

  resources :users, only: [:show], module: :users do
    resource :dashboard, only: [:show]
    resources :devices, except: [:update, :edit] do
      member do
        delete "checkin"
        post "switch_privilege_for_developer"
        put "fog"
      end
      collection do
        get "add_current"
      end
    end
    resources :approvals, only: [:index] do
      member do
        post "approve"
        post "reject"
      end 
    end
  end



  # Devs
  resources :developers, only: [:edit, :update]

  namespace :developers do
    resource :console, only: [:show]
    resources :approvals, only: [:index, :new, :create]
  end


  # Checkins
  resources :checkins, only: [:index, :show, :destroy]

end
