require 'bundler/capistrano'

load 'deploy/assets'

set :user, 'doggy'
set :domain, '185.21.100.187'
set :applicationdir, '/var/www/doggytag'

ssh_options[:forward_agent] = true

role :web, domain
role :app, domain
role :db, domain, primary: true

set :application, 'DoggyTag'
set :repository, 'git@github.com:DerKobe/doggytag.git'
set :scm, :git
set :branch, 'master'
set :default_environment, { PATH: '/home/doggy/.rbenv/shims:$PATH' }

# deploy config
set :deploy_to, applicationdir

default_run_options[:pty] = true

#after 'deploy:restart', 'deploy:cleanup'

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
