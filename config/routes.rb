Rails.application.routes.draw do
  root "dashboard#index"
  get "/signup", to: "users#new"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users do
    resources :subscriptions
    resources :tags
    resources :payment_methods
  end
end
