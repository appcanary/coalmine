source 'https://rubygems.org'

ruby '2.2.0'

gem 'rails', '4.2.6'
# gem 'rails', '4.2.0'

gem 'pg'
gem 'redis'
gem 'rollout'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# views / assets
gem 'sassc-rails', '~> 1.1.0'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'jquery-rails'
gem 'uglifier', '>= 1.3.0'
gem "font-awesome-rails"
gem "bourbon"
gem "neat"
gem "htmlentities"
gem 'haml', '~> 4.0.6'

# auth
gem 'sorcery'
gem 'pretender'

# model stuff
gem 'httparty'
gem 'active_model_serializers', '~> 0.10.0'


# gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
# gem 'jquery-rails'

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
gem 'intercom'


gem 'que', '~> 0.11.6'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem 'better_errors'

  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'

  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  # gem 'm'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'fixtures_dumper'
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
end
