source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '4.2.6'

gem 'pg'
gem 'rollout'
gem 'rollout_postgres_store'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# views / assets
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'jquery-rails'
gem 'uglifier', '>= 1.3.0'
gem "font-awesome-rails"
gem "bourbon"
gem "neat"
gem "htmlentities"
gem 'haml', '~> 4.0.6'
gem 'redcarpet'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

gem 'reform'
gem 'reform-rails'

# auth
gem 'sorcery'
gem 'pretender'

# model stuff
gem 'httparty'
gem 'active_model_serializers', '~> 0.10.0'
gem 'has_secure_token'
gem 'sunspot_rails'

# gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# external services
gem 'sentry-raven', '~> 0.13.3'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'intercom'

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

gem 'que', '~> 0.12.0'

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
  gem 'sunspot_solr'
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
end
