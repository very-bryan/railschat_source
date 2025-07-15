Rails.application.routes.draw do
  # Logout route
  get "logout", to: "sessions#destroy", as: :logout
  
  # Devise routes with omniauth callbacks
  devise_for :users, controllers: { 
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  
  # Workspace routes
  resources :workspaces, only: [:new, :create, :destroy]
  resources :workspace_members, only: [:index, :create, :update, :destroy]
  
  # Sample data routes
  delete "sample_data", to: "sample_data#destroy"
  
  # Search routes
  get "search", to: "search#index"
  # Notifications routes
  resources :notifications, only: [:index, :show, :update, :destroy] do
    collection do
      post :mark_all_read
    end
  end
  # Settings routes
  get "settings", to: "settings#index"
  patch "settings", to: "settings#update"
  patch "settings/workspace", to: "settings#update_workspace", as: :update_workspace_settings
  
  # Profile routes
  resource :profile, only: [:show, :edit, :update, :destroy] do
    patch :notifications, on: :member
  end
  # Reports routes
  get "reports", to: "reports#index"
  get "reports/analytics", to: "reports#analytics"
  # Calendar routes
  get "calendar", to: "calendar#index"
  
  # Root route
  root "dashboard#index"
  
  # Dashboard routes
  get "dashboard", to: "dashboard#index"
  
  # Notes routes
  resources :notes do
    member do
      patch :update_date
    end
    resources :comments, only: [:create, :destroy]
  end
  
  # Kanban routes
  get "kanban", to: "kanban#index"
  patch "kanban/update_status", to: "kanban#update_status"
  
  # Chat routes
  get "chat", to: "chat#index"
  get "chat/channel/:id", to: "chat#show", as: :chat_channel
  
  # Messages routes
  resources :messages, only: [:create, :edit, :update, :destroy] do
    member do
      post 'reactions', to: 'messages#reactions'
      post 'reactions/toggle', to: 'messages#toggle_reaction'
      post 'toggle_reaction'
      post 'save'
      post 'pin'
      get 'thread'
      post 'share'
    end
  end
  
  # Channels routes
  resources :channels, only: [:index, :show, :create] do
    member do
      get :members
      post :update_members
      post :toggle_favorite
      get :mentionable_users
    end
    resources :messages, only: [:create, :edit, :update, :destroy]
  end
  
  # Admin routes
  namespace :admin do
    root 'dashboard#index'
    resources :users do
      member do
        patch :toggle_admin
      end
    end
    resources :workspaces
    resources :notes, only: [:index, :show, :destroy]
  end
  
  # Super Admin routes
  namespace :super_admin do
    # Sessions
    get "login", to: "sessions#new", as: :new_session
    post "login", to: "sessions#create", as: :sessions
    delete "logout", to: "sessions#destroy", as: :destroy_session
    
    root "dashboard#index"
    resources :workspaces
    resources :users do
      member do
        patch :toggle_super_admin
        post :impersonate
      end
      collection do
        post :stop_impersonating
      end
    end
    get "billing", to: "billing#index"
    get "analytics", to: "analytics#index"
    get "settings", to: "settings#index"
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
