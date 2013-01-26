Omnisentry::Application.routes.draw do
  resources :items

  resources :users
  resources :user_sessions

  get "log_out" => "user_sessions#destroy", :as => "log_out"
  get "log_in" => "user_sessions#new", :as => "log_in" 

  root :to => "welcome#index"
end
