Rails.application.routes.draw do
  get 'timeline' => "timeline#index"

  resources :user_sessions, :only => [:create, :destroy]
  resources :apps, :only => [:index, :new, :show] do
    resources :servers, :only => [:index, :show]
  end
  
  resources :servers, :only => [:index, :new, :show]

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  resources :users
  get 'sign_up' => "users#new", :as => :sign_up
  post 'sign_up' => "users#create"

  resources :events, :only => [:index]
  
  root 'welcome#index'

  post 'beta/list' => "welcome#beta_list"
  get 'dashboard' => "dashboard#index", :as => :dashboard
  get 'welcome' => "dashboard#index", :as => :welcome
end
