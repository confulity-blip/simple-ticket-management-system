Rails.application.routes.draw do
  namespace :api do
    # Authentication
    post 'sessions', to: 'sessions#create'      # Login
    delete 'sessions', to: 'sessions#destroy'   # Logout
    get 'sessions/current', to: 'sessions#current'  # Get current user
    get 'me', to: 'sessions#current'            # Alias for current user

    # Analytics
    get 'analytics/dashboard', to: 'analytics#dashboard'

    # Tickets
    resources :tickets do
      member do
        post :assign  # POST /api/tickets/:id/assign
      end

      # Nested comments
      resources :comments, only: [:index, :create]
    end

    # Users (for listing agents, user management)
    resources :users, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :agents  # GET /api/users/agents (list agents for assignment)
      end
    end

    # Tags
    resources :tags, only: [:index, :create, :show, :update, :destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
