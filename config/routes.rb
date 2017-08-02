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

  class RubysecConstraint
    def self.matches?(request)
      Rails.configuration.rubysec.domains.include? request.host
    end
  end


  constraints IsItVulnConstraint do
    root 'is_it_vuln#index', :as => :vuln_root
    post '/submit' => "is_it_vuln#submit", :as => :submit_gemfile
    get '/results/sample' => "is_it_vuln#sample_results", :as => :sample_results
    get '/results/:ident' => "is_it_vuln#results", :as => :vuln_results
  end

  constraints RubysecConstraint do
    root "rubysec#index", :as => :rubysec_root
    get "/new" => "rubysec#new", :as => :rubysec_new
    post "/preview" => "rubysec#preview", :as => :rubysec_preview
    post "/create" => "rubysec#create", :as => :rubysec_create
  end

  get 'solutions/soc2' => 'soc2#index', :as => :soc2_solutions

  get "isitvuln" => "is_it_vuln#index"

  root 'welcome#index'
  get 'launchrock' => 'welcome#index'
  post 'beta/list' => "welcome#beta_list"

  get 'pricing' => 'welcome#pricing'

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get 'dashboard' => "dashboard#index", :as => :dashboard
  get 'dashboard/report' => "dashboard#report", :as => :dashboard_report
  get 'history' => "dashboard#history", :as => :history

  get 'summaries' => "summaries#index", :as => :summary_index
  get 'summaries/:date' => "summaries#show", :as => :summary

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


  resources :docs, :only => :index do
    get "api", as: :api, on: :collection
    get "ci", as: :ci, on: :collection
    get "agent_upgrade", as: :agent_upgrade, on: :collection
    get "agent", as: :agent, on: :collection
  end

  resources :users, :only => [:new, :create, :update, :destroy] do
    post "stop_impersonating", on: :collection
  end
  resources :password_reset, :only => [:show, :update]

  resource :settings, :only => [:show, :update] do
    patch 'reset_token', on: :collection
    post 'webhook', on: :collection
    delete 'webhook' => "settings#delete_webhook", on: :collection
  end

  resources :user_sessions, :only => [:create, :destroy]

  resources :servers, :only => [:new, :show, :destroy, :edit, :update] do
    resources :apps, :only => [:index, :new, :show, :destroy]

    get "install", on: :collection
    get "deb", on: :collection
    get "rpm", on: :collection

    delete "destroy_inactive" => "servers#destroy_inactive", :as => :destroy_inactive, :on => :collection
  end

  get "/servers/:id/procs" => "servers#procs"

  resources :monitors, :only => [:new, :show, :destroy, :create] do
    post "ignore_vuln/:package_id", action: :ignore_vuln, on: :collection, as: :ignore_vuln
    delete "unignore_vuln/:package_id", action: :unignore_vuln, on: :collection, as: :unignore_vuln

    post "resolve_vuln/:package_id", action: :resolve_vuln, on: :collection, as: :resolve_vuln
    delete "unresolve_vuln/:package_id", action: :unresolve_vuln, on: :collection, as: :unresolve_vuln
  end

  get "vulns/:platform" => "vulns#index", :as => :platform_vulns, :constraints => ->(req) {Platforms.supported?(req.params[:platform])}

  resources :vulns, :only => [:index, :show] do
    get "archive/:id" => "vulns#archive", :as => "archive"
  end

  get "cves/:cve_id" => "cves#show", :as => :cve

  get "packages/php/:name/:version" => "packages#show", :as => :php_package_version, :constraints => { :name => /[^\/]+\/[^\/]+/, :version => /[^\/]+/ }
  get "packages/:platform/:name/:version" => "packages#show", :as => :package_platform, :constraints => { :platform => /[^\/]+/, :name => /[^\/]+/, :version => /[^\/]+/ }
  get "packages/:platform/:release/:name/:version" => "packages#show", :as => :package_platform_release, :constraints => { :platform => /[^\/]+/, :release => /[^\/]+/, :name => /[^\/]+/, :version => /[^\/]+/ }
  get "packages/:id" => "packages#show", :as => :package, :constraints => { :platform => /[^\/]+/, :name => /[^\/]+/, :version => /[^\/]+/ }

  resources :logs, :only => :index
  resources :emails, :only => [:index, :show]

  namespace :admin do
    root to: "users#index"
    resources :users do
      post "impersonate", on: :member
    end

    resources :subscription_plans
    resources :emails, :only => [:index, :show]
  end

  namespace :api do
    scope :v3 do
      post "check" => 'check#create'
      get "status" => 'status#status'

      post "monitors(/:name)" => "monitors#create", :constraints => { :name => /.*/ }
      put "monitors/:name" => "monitors#create_or_update", :constraints => { :name => /.*/ }
      get "monitors/:name" => "monitors#show", :as => "monitor", :constraints => { :name => /.*/ }
      get "monitors" => "monitors#index"
      delete "monitors/:name" => "monitors#destroy", :constraints => { :name => /.*/ }

      get "servers/:uuid" => "servers#show", :as => "server"
      get "servers" => "servers#index"
      delete "servers/inactive" => "servers#destroy_inactive", :as => :inactive_servers
      delete "servers/:uuid" => "servers#destroy"
    end

    scope :v2 do
      post "check" => 'check#create', as: "v2_check"
      get "status" => 'status#status'

      post "monitors(/:name)" => "monitors#create"
      put "monitors/:name" => "monitors#create_or_update"
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
        put "servers/:uuid/processes" => "agent#update_server_processes"
      end
    end
  end

end
