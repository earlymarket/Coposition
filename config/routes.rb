Rails.application.routes.draw do
  use_doorkeeper do
    controllers applications: "oauth/applications",
                authorizations: "oauth/authorizations",
                tokens: "oauth/tokens"
  end

  ActiveAdmin.routes(self)
  mount ActionCable.server => "/cable"
  root to: "welcome#index"

  # Specified routes

  get "/api", to: "welcome#api"
  get "/help", to: "welcome#help"
  get "/getting_started", to: "welcome#getting_started"
  get "/terms", to: "welcome#terms"
  get "/devs", to: "welcome#devs"
  get "settings/unsubscribe"
  patch "settings/update"

  # Devise

  devise_for :users, controllers: {
    registrations: "users/devise/registrations",
    sessions: "users/devise/sessions"
  }
  devise_for :developers, controllers: {
    registrations: "developers/devise/registrations",
    sessions: "developers/devise/sessions"
  }

  # Attachinary
  mount Attachinary::Engine => "/attachinary"

  # API

  namespace :api, path: "", constraints: { subdomain: "api" }, defaults: { format: "json" } do
    scope module: :v1, constraints: Constraints::ApiConstraint.new(version: 1, default: true) do
      resources :subscriptions, only: [:create, :destroy]
      resources :configs, only: [:index, :show, :update]
      resource :uuid, only: [:show]
      resources :checkins, only: [:create] do
        collection do
          post :batch_create
        end
      end
      resources :developers, only: [:index, :show]
      resources :demo do
        collection do
          get :reset_approvals
          get :demo_user_approves_demo_dev
        end
      end
      resources :users, only: [:show, :index] do
        collection do
          get :auth
        end
        resources :locations, only: :index, module: :users
        resources :approvals, only: [:create, :index, :update, :destroy], module: :users do
          collection do
            get :status
          end
        end
        resources :checkins, only: [:index] do
          collection do
            get :last
          end
        end
        resources :requests, only: [:index], module: :users do
          collection do
            get :last
          end
        end
        resources :devices, only: [:index, :create, :show, :update], module: :users do
          resources :permissions, only: [:update, :index]
          put "/permissions", to: "permissions#update_all"
        end
      end
      namespace :mobile_app do
        resources :sessions, only: [:create, :destroy]
      end
    end
    match "*path", to: -> (_env) { [404, {}, ["{'error': 'route_not_found'}"]] }, via: :all
  end

  # Users
  resources :users, only: [:show], module: :users do
    resource :dashboard, only: [:show]
    resources :devices, except: :edit do
      member do
        get :shared, :info
        post :remote_checkin
      end
      resources :checkins, only: [:index, :show, :create, :new, :update] do
        collection { post :import }
      end
      delete "/checkins/", to: "checkins#destroy_all"
      delete "/checkins/:id", to: "checkins#destroy"
      resources :permissions, only: [:update, :index]
    end
    resources :approvals, only: [:new, :create, :update, :destroy]
    resource :create_dev_approvals, only: :create
    resources :friends, only: [:show] do
      member do
        get "show_device"
      end
    end
    get "/apps", to: "approvals#index", defaults: { approvable_type: "Developer" }
    get "/friends", to: "approvals#index", defaults: { approvable_type: "User" }
    collection do
      get :me
    end
    resources :countries, only: :index
  end

  # Devs
  resources :developers, only: [:edit, :update]

  # Release notes
  resources :release_notes

  resources :activities, only: :index

  namespace :developers do
    get "/", to: "consoles#show"
    resource :console, only: [:show] do
      collection { post "key" }
    end
    resources :approvals, only: [:index, :new, :create, :destroy]
    # For cool API usage stats in the future
    resources :requests, only: [:index] do
      collection do
        put :pay
      end
    end
  end
end
