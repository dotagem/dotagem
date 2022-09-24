# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"

set :application, "dotagem"
set :repo_url, "https://github.com/dotagem/dotagem.git"

# Default branch, GITHUB_SHA is assigned by release event on github actions
set :branch do
  ENV["GITHUB_SHA"] || "main"
end

# We want to restart the nice way
set :passenger_restart_with_touch, false

append :linked_dirs,  'log',           'tmp/pids',      'tmp/cache', 
                      'tmp/sockets',   'vendor/bundle', '.bundle',
                      'public/system', 'public/uploads'
append :linked_files, 'config/master.key'

set :rbenv_type, :user
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} /usr/bin/rbenv exec"

after "deploy:published", "telegram:set_webhook"
