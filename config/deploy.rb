# config valid only for Capistrano 3.1
lock '3.4.1'

set :application, 'canary-web'
set :repo_url, 'git@github.com:appcanary/coalmine.git'

set :rails_env, (fetch(:stage) || fetch(:rails_env))
# Default branch is :master
# TODO GET RID OF THIS IN PROD
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/canary-web'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets tmp/importers vendor/bundle public/system public/sitemaps config/settings/secrets}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    on roles(:app) do
      execute "sudo systemctl reload-or-restart unicorn"
      execute "sudo systemctl reload-or-restart que"
    end
  end

  task :seed do
    on roles(:app) do
      execute "cd #{deploy_path}/current && bundle exec rake db:seed RAILS_ENV=#{fetch(:rails_env)}"
    end
  end
end
before 'deploy:compile_assets', 'deploy:compile_webpack_assets'
namespace :deploy do
  task :compile_webpack_assets do
    on roles(:app) do
      execute "cd #{release_path} && bundle exec rake webpack:compile RAILS_ENV=#{fetch(:rails_env)}"
    end
  end
end

namespace :deploy do
  task :db_rollback do
    on roles(:app) do
      execute "cd #{release_path} && bundle exec rake db:rollback RAILS_ENV=#{fetch(:rails_env)}"
    end
  end
end

namespace :debug do
  desc "tail rails logs" 
  task :logs do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log  #{shared_path}/log/unicorn*.log"
    end
  end
end

namespace :incredible do
  namespace :journey do
    task :complete do
      on roles(:app) do
        execute "cd #{release_path} && bundle exec rake incredible:journey:complete RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end
end

# namespace :deploy do
# 
#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # Your restart mechanism here, for example:
#       # execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end
# 
#   after :publishing, :restart
# 
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end
# 
# end
