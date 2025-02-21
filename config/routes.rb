Rails.application.routes.draw do
  devise_for :users
  root "products#index"

  resources :users  # No need for the duplicate only: [:show]
  resources :products
  resources :orders
  resource :profile, only: [:show, :edit, :update]

  # Cart Routes
  resource :cart, only: [:show] do
    post 'add_item', to: 'carts#add_item'
    delete 'remove_item/:id', to: 'carts#remove_item', as: 'remove_item'
  end

  resources :products do
    post 'buy', on: :member # This creates a route for /products/:id/buy
  end
  
  resources :orders

  # Health Check Route
  get "up" => "rails/health#show", as: :rails_health_check
  
end
