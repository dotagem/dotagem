# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"

set :application, "dotagem"
set :repo_url, "https://github.com/cschuijt/dotagem.git"

# Default branch
set :branch, "main"

# We want to restart the nice way
set :passenger_restart_with_touch, false

append :linked_dirs,  'log',           'tmp/pids',      'tmp/cache', 
                      'tmp/sockets',   'vendor/bundle', '.bundle',
                      'public/system', 'public/uploads'
append :linked_files, 'config/master.key'
