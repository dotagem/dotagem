source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

gem "pg", "~> 1.5.3"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.2"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 5.0.5"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # Use Rspec for testing
  gem 'rspec-rails', '~> 6.1.1'
  gem 'factory_bot_rails', '~> 6.2.0'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "foreman", "~> 0.87.2"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver", '~> 4'
  gem "webdrivers"
end

gem 'telegram-bot', '~> 0.15.6'
gem 'httparty', '~> 0.20'

gem 'omniauth', '~> 2.1.1'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-steam'
gem 'omniauth-telegram', github: 'dotagem/omniauth-telegram', branch: 'master'

# https://github.com/Dragaera/steam-id#readme
gem 'steam-condenser', github: 'koraktor/steam-condenser-ruby', ref: '3ee580b'
gem 'steam-id2', github: 'Dragaera/steam-id', branch: 'master'

gem 'hashie', '~> 5.0.0'

gem "tailwindcss-rails", "~> 2.0"

gem "capistrano", "~> 3.17", require: false
gem "capistrano-rails", "~> 1.6", require: false
gem "capistrano-rbenv", require: false
gem "capistrano-passenger", require: false

gem 'ed25519', '>= 1.2', '< 2.0'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'

gem "rexml"

gem "dockerfile-rails", ">= 1.5", :group => :development

gem 'sentry-ruby'
gem 'sentry-rails'
