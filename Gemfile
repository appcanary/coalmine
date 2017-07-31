source 'https://rubygems.org'

ruby '2.3.4'

gem 'rails', '4.2.7.1'

gem 'pg'
gem 'rollout'
gem 'rollout_postgres_store'
gem 'que', '~> 0.12.0'
gem 'whenever', :require => false

# views / assets
gem 'sass-rails', require: false
gem 'sassc-rails', :git => "git@github.com:appcanary/sassc-rails.git"
gem 'bootstrap-sass', :git => "git@github.com:appcanary/bootstrap-sass.git"
gem 'jquery-rails', '~> 4.0.4'
gem 'uglifier', '~> 2.7.1'
gem "font-awesome-rails"
gem "bourbon", :git => "git@github.com:appcanary/bourbon.git", :branch => "v4-stable"
gem "neat", :git => "git@github.com:appcanary/neat.git"
gem "htmlentities"
gem 'haml', '~> 4.0.6'
gem 'redcarpet'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

gem 'premailer-rails'
# required for premailer?
gem 'nokogiri', '~> 1.7.1'

# handling user input
gem 'reform'
gem 'reform-rails'

# auth
gem 'sorcery'
gem 'pretender'

# model stuff
gem 'httparty'
gem 'active_model_serializers', '~> 0.10.0'
gem 'has_secure_token'
gem 'pluck_to_hash'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# external services
gem 'sentry-raven', '~> 2.4.0'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'intercom'
gem 'ddtrace', '0.7.2', :group => :production
gem 'sitemap_generator', '5.3.1'

# importer utilities
gem 'php-composer-semver', :require => 'composer/semver'

# deployment
gem 'unicorn-rails'
gem 'capistrano', '~> 3.4.0'
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano-rails-console'
gem 'capistrano-npm'
gem 'capistrano-deploytags', '~> 1.0.0'

# dev tools
gem 'pry-rails'
gem 'binding_of_caller'

#parsers
gem "msgpack"


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem 'better_errors'

  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'

  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'minitest-ci'
  # gem 'm'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'fixtures_dumper'
  gem 'foreman'
end

group :test do
  gem 'mocha', '~> 1.1.0'
  gem 'webmock', '~> 1.21.0'
  gem 'vcr', '~> 2.9.3'
  gem 'database_cleaner', '~> 1.5.3'
end


group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'annotate'
  gem 'letter_opener'
  gem 'bullet'
  gem 'rack-mini-profiler'
  # For memory profiling (requires Ruby MRI 2.1+)
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs (requires Ruby MRI 2.0.0+)
  gem 'flamegraph'
  gem 'stackprof'     # For Ruby MRI 2.1+
  gem 'fast_stack'    # For Ruby MRI 2.0
end
