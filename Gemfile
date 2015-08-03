source 'https://rubygems.org'

ruby '2.2.0'

gem 'rails', '4.2.0'

# Use sqlite3 as the database for Active Record
gem 'pg'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# views / assets
gem 'sass-rails', '~> 5.0'
gem 'compass-rails', '~> 2.0.4'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'jquery-rails'
gem 'uglifier', '>= 1.3.0'
gem "font-awesome-rails"
gem "bourbon"
gem "neat"
gem "htmlentities"
gem 'haml', '~> 4.0.6'
gem 'haml-coffee', '~> 0.1.0'

# auth
gem 'sorcery'
gem 'pretender'

# model stuff
gem 'annotate'
gem 'httparty'
gem 'active_model_serializers'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# external services
gem 'sentry-raven', '~> 0.13.3'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

# deployment
gem 'unicorn-rails'
gem 'capistrano', '~> 3.2.0'
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano3-unicorn'
gem 'capistrano-rails-console'
gem 'capistrano-npm'
gem 'capistrano-deploytags', '~> 1.0.0'

# dev tools
gem 'pry-rails'
gem 'binding_of_caller'

# API Client
gem 'faraday', '~> 0.9.1'
gem 'faraday_middleware', '~> 0.9.1'

#misc
gem 'ruby_identicon', '0.0.4'
gem 'request_store', '~> 1.1.0'
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem 'better_errors'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'm'
  gem 'faker'
  gem 'factory_girl_rails'
end

group :test do
  gem 'mocha', '~> 1.1.0'
  gem 'webmock', '~> 1.21.0'
  gem 'vcr', '~> 2.9.3'
end

group :development do
  gem "rack-livereload"
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'guard-minitest'
  gem 'guard-ctags-bundler'
  gem 'foreman'
end
