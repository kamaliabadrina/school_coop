Rails.application.routes.draw do
  devise_for :users
  root "products#index"

  resources :users  
  resources :products
  resources :orders, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      get :success # Route for the success page
    end
  end
  resource :profile, only: [:show, :edit, :update]

  # Cart Routes
  resource :cart, only: [:show] do
    post 'add_item', to: 'carts#add_item'
    delete 'remove_item/:id', to: 'carts#remove_item', as: 'remove_item'
  end

  resources :products do
    post 'buy', on: :member # This creates a route for /products/:id/buy
  end
  
  # Health Check Route
  get "up" => "rails/health#show", as: :rails_health_check
end
