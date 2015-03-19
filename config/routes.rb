Rails.application.routes.draw do
  get 'events' => "events#index"

  resources :user_sessions, :only => [:create, :destroy]
  resources :apps, :only => [:index, :show] do
    resources :servers, :only => [:index, :show]
  end
  
  resources :servers, :only => [:index, :show]

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  resources :users
  get 'sign_up' => "users#new", :as => :sign_up
  post 'sign_up' => "users#create"

  root 'welcome#index'

  post 'beta/list' => "welcome#beta_list"
  get 'dashboard' => "dashboard#index", :as => :dashboard
end
