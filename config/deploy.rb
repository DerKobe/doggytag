require 'bundler/capistrano'

load 'deploy/assets'

set :user, 'doggy'
set :domain, '185.21.100.187'
set :applicationdir, '/var/www/doggytag'

role :web, domain
role :app, domain
role :db, domain, primary: true

set :application, 'DoggyTag'
set :repository, 'git@gitlab.sys.mixxt.net:kobe/koeter_tag.git'
set :scm, :git
set :branch, 'master'
#set :scm_verbose, true
set :default_environment, { PATH: '/home/doggy/.rbenv/shims:$PATH' }

# deploy config
set :deploy_to, applicationdir
#set :deploy_via, :export

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