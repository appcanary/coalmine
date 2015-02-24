Rails.application.routes.draw do
  resources :users
  resources :user_sessions

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get 'sign_up' => "users#new", :as => :sign_up
  post 'sign_up' => "users#create"

  root 'welcome#index'

  post 'beta/list' => "welcome#beta_list"
  get 'dashboard' => "dashboard#index", :as => :dashboard
end
