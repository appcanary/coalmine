source 'https://rubygems.org'

ruby '2.2.0'

gem 'rails', '4.2.0'

# Use sqlite3 as the database for Active Record
gem 'pg'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# views / assets
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'jquery-rails'
gem 'uglifier', '>= 1.3.0'
gem "font-awesome-rails"

# auth
gem 'sorcery'

# model stuff
gem 'annotate'
gem 'httparty'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# deployment
gem 'unicorn-rails'
gem 'capistrano', '~> 3.2.0'
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano3-unicorn'

# dev tools
gem 'pry-rails'
gem 'binding_of_caller'

#misc 
gem 'ruby_identicon', '0.0.4'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'm'
  gem 'factory_girl_rails'
  gem 'faker'
end


group :development do
  gem "rack-livereload"
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'guard-minitest'
end
