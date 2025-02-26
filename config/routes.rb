Rails.application.routes.draw do
  devise_for :users
  root "products#index"

  resources :users  
  resources :products
  resources :orders, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      get :success
    end
  end

  resource :profile, only: [:show, :edit, :update]

  # Cart Routes
  resource :cart, only: [:show] do
    post 'add_item', to: 'carts#add_item'
    delete 'remove_item', to: 'carts#remove_item', as: 'remove_item' # Removed :id from route
  end

  resources :products do
    post 'buy', on: :member
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
