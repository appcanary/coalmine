Rails.application.routes.draw do

  match "/404", :to => "errors#error_not_found", :as => :not_found, :via => :all
  match "/422", :to => "errors#error_unacceptable", :as => :unacceptable, :via => :all
  match "/500", :to => "errors#error_internal_error", :as => :internal_error, :via => :all


  # routing for isitvulnerable.com
  class IsItVulnConstraint
    def self.matches?(request)
      Rails.configuration.is_it_vuln.domains.include? request.host
    end
  end

  constraints IsItVulnConstraint do
    root 'is_it_vuln#index', :as => :vuln_root
    post '/submit' => "is_it_vuln#submit", :as => :submit_gemfile
    get '/results/sample' => "is_it_vuln#sample_results", :as => :sample_results
    get '/results/:ident' => "is_it_vuln#results", :as => :vuln_results
  end
  
  get "isitvuln" => "is_it_vuln#index"

  root 'welcome#index'
  get 'launchrock' => 'welcome#index'
  post 'beta/list' => "welcome#beta_list"

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get 'dashboard' => "dashboard#index", :as => :dashboard
  get 'history' => "dashboard#history", :as => :history

  get 'welcome' => "onboarding#welcome", :as => :onboarding


  get "secretsignup/:source" => "users#new", :as => :new_beta_sign_up
  get "hey_hn" => "users#new"
  post "secretsignup/:source" => "users#create", :as => :beta_sign_up

  post "presignup" => "users#pre_sign_up", :as => :pre_sign_up
  get 'sign_up' => "users#new", :as => :sign_up
  post 'sign_up' => "users#create", :as => :create_sign_up

  get "billing" => "billing#show", :as => :show_billing
  put "billing" => "billing#update", :as => :billing

  get "legal/privacy" => "static#privacy", :as => :privacy_policy

  # microsites
  get 'greatrubyreview' => "great_review#show", :as => :great_review
  get 'greatrubyreview/hello' => "great_review#hello", :as => :great_review_login
  post 'greatrubyreview/sign_up' => "great_review#sign_up", :as => :great_review_sign_up
  post 'greatrubyreview/payment' => "great_review#payment", :as => :great_review_payment


  resources :docs, :only => :index

  resources :users, :only => [:new, :create, :destroy] do
    post "stop_impersonating", on: :collection
  end
  resources :password_reset, :only => [:show, :update]
  
  resource :settings, :only => [:show, :update] do
    patch 'reset_token', on: :collection
  end

  resources :user_sessions, :only => [:create, :destroy]

  resources :servers, :only => [:new, :show, :destroy, :edit, :update] do
    resources :apps, :only => [:index, :new, :show]
    get "install", on: :collection
    get "deb", on: :collection
    get "rpm", on: :collection

    delete "destroy_inactive" => "servers#destroy_inactive", :as => :destroy_inactive, :on => :collection
  end

  resources :monitors, :only => [:new, :show, :destroy, :create]
  resources :vulns, :only => [:index, :show] do
    get "archive/:id" => "vulns#archive", :as => "archive"
  end

  resources :logs, :only => :index
  resources :emails, :only => [:index, :show]

  namespace :admin do
    root to: "users#index"
    resources :users do
      post "impersonate", on: :member
    end

    resources :subscription_plans
  end

  namespace :api do
    scope :v3 do
      post "check" => 'check#create'
      get "status" => 'status#status'

      post "monitors(/:name)" => "monitors#create"
      put "monitors/:name" => "monitors#update"
      get "monitors/:name" => "monitors#show", :as => "monitor"
      get "monitors" => "monitors#index"
      delete "monitors/:name" => "monitors#destroy"

      get "servers/:uuid" => "servers#show", :as => "server"
      get "servers" => "servers#index"
      delete "servers/:uuid" => "servers#destroy"
    end

    scope :v2 do
      post "check" => 'check#create', as: "v2_check"
      get "status" => 'status#status'

      post "monitors(/:name)" => "monitors#create"
      put "monitors/:name" => "monitors#update"
      get "monitors/:name" => "monitors#show", :as => "v2_monitor"
      get "monitors" => "monitors#index", :as => "v2_monitors"
      delete "monitors/:name" => "monitors#destroy"

      get "servers/:uuid" => "servers#show", :as => "v2_server"
      get "servers" => "servers#index", :as => "v2_servers"
      delete "servers/:uuid" => "servers#destroy"
    end


    scope :v1 do
      scope :agent do
        post "servers" => "agent#create", :as => :agent_servers
        put "servers/:uuid" => "agent#update", :as => :agent_server_update
        get "servers/:uuid" => "agent#show", :as => :agent_server_upgrade
        post "heartbeat/:uuid" => "agent#heartbeat", :as => :agent_server_heartbeat
      end
    end
  end

end
