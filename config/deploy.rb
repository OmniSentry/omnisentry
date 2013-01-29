require "capistrano/ext/multistage"

# Application Name
set :application, "omnisentry"

# Where we are deploying to
set :location, "ec2-50-17-7-100.compute-1.amazonaws.com"

# Multistage deployment. Each one of these corresponds to a <env_name>.rb file in config/deploy/ which contains specific options for each stage
set :stages, ["production"]
set :default_stage, "production"

set :deploy_to, "/home/deploy/omnisentry/"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :deploy_via, :copy
set :scm, :git
set :repository,  "git@github.com:OmniSentry/omnisentry.git"
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m

# Setup connection options. Set up your ec2 permissions via ssh-add and this option will allow you to connect
set :user, "deploy"
set :use_sudo, false
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true

# Set up the different roles. These can be different locations for more complex deployments, or the same for simple deployment.
role :web, location
role :app, location
role :db, location, :primary => true

# Enable Capistrano use with rvm.
require 'rvm/capistrano'

# Specify gemset you want to use on server.
set :rvm_ruby_string, '1.9.3@omnisentry' 
set :rvm_type, :user

# Enable Capistrano use with Bundler
require 'bundler/capistrano'

# Run a bundle update on the remote (should not be necessary)
namespace :bundle do
  task :update do
    run "cd #{current_path} && bundle update"
  end
end

require 'capistrano-unicorn'

set :unicorn_pid, '/home/deploy/omnisentry/shared/pids/unicorn.pid'
  
after 'deploy:start', 'unicorn:start'
after 'deploy:restart', 'unicorn:reload'

namespace :deploy do
  task :restart do
    run "#{sudo} /usr/sbin/nginx -s reload -c /home/deploy/etc/nginx/nginx.conf"
  end

  task :start do
    run "#{sudo} /usr/sbin/nginx -c /home/deploy/etc/nginx/nginx.conf"
  end

  task :migrate do 
    run "cd #{current_path} && rake db:migrate"
  end
end

load 'deploy/assets'

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end




