Rails.application.routes.draw do
  get "users/new"
  root "application#hello"
  get "/signup", to: "users#new"
  resources :users
end
