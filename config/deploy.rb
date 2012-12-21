require "capistrano/ext/multistage"

# Application Name
set :application, "omnisentry"

# Where we are deploying to
set :location, "ec2-23-20-227-105.compute-1.amazonaws.com"

# Multistage deployment. Each one of these corresponds to a <env_name>.rb file in config/deploy/ which contains specific options for each stage
set :stages, ["production"]
set :default_stage, "production"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :deploy_via, :copy
set :scm, :git
set :repository,  "git@github.com:OmniSentry/omnisentry.git"

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
