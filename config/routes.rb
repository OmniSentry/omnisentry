Omnisentry::Application.routes.draw do
  resources :users
  root :to => "users#create"
end
