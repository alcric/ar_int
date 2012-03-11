set :application, "alwaysresolve.net"
set :repository,  "git@github.com:alzuin/ar_int.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "www.alwaysresolve.net"                          # Your HTTP server, Apache/etc
role :app, "www.alwaysresolve.net"                          # This may be the same as your `Web` server
role :db,  "www.alwaysresolve.net", :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

set :user, 'deploy'
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
ssh_options[:port] = 8925

after "deploy", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:restart"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :bundle_gems do
    run "cd #{deploy_to}/current && bundle install"
  end
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end