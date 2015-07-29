Rails.application.routes.draw do
  root 'welcome#index'
  get 'launchrock' => 'welcome#index'
  post 'beta/list' => "welcome#beta_list"

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get 'dashboard' => "dashboard#index", :as => :dashboard
  get 'welcome' => "dashboard#index", :as => :welcome


  get "secretsignup/:source" => "users#new", :as => :new_beta_sign_up
  get "hey_hn" => "users#new"
  post "secretsignup/:source" => "users#create", :as => :beta_sign_up

  #get 'sign_up' => "users#new", :as => :sign_up
  #post 'sign_up' => "users#create"

  get "hello" => "servers#onboarding", :as => :onboarding

  put "billing" => "billing#update", :as => :billing

  resources :users, :only => [:new, :create, :destroy] do
    post "stop_impersonating", on: :collection
  end
  
  resource :settings, :only => [:show, :update]

  resources :user_sessions, :only => [:create, :destroy]

  resources :servers, :only => [:new, :show, :destroy, :edit, :update] do
    resources :apps, :only => [:index, :new, :show]
    get "install", on: :collection
    get "deb", on: :collection
    get "rpm", on: :collection
  end

  resources :vulns, :only => [:show]

  namespace :admin do
    root to: "users#index"
    resources :users do
      post "impersonate", on: :member
    end
  end
end
