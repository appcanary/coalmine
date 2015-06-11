Rails.application.routes.draw do
  root 'welcome#index'
  get 'launchrock' => 'welcome#index'
  post 'beta/list' => "welcome#beta_list"

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get 'dashboard' => "dashboard#index", :as => :dashboard
  get 'welcome' => "dashboard#index", :as => :welcome


  resources :users
  #get 'sign_up' => "users#new", :as => :sign_up
  #post 'sign_up' => "users#create"

  resource :current_user, :only => [:edit, :update], controller: 'current_user'

  get 'timeline' => "timeline#index"
  resources :user_sessions, :only => [:create, :destroy]
  
  resources :servers, :only => [:index, :new, :show] do
    resources :apps, :only => [:index, :new, :show]
  end

  resources :vulns, :only => [:show]

  # resources :events, :only => [:index]
  # resources :apps, :only => [:index, :new, :show] do
  #   resources :servers, :only => [:index, :show]
  # end


end
