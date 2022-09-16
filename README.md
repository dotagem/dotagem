# 💎 Gem of True Sight
##### A Telegram bot that fetches and displays stats and Dota 2 data

![RSpec](https://github.com/cschuijt/dotagem/actions/workflows/tests.yml/badge.svg)


![GitHub release (latest by date)](https://img.shields.io/github/v/release/cschuijt/dotagem?label=latest%20release)
![GitHub Release Date](https://img.shields.io/github/release-date/cschuijt/dotagem?label=release%20date)
![Deploy](https://github.com/cschuijt/dotagem/actions/workflows/deploy.yml/badge.svg)


![GitHub last commit](https://img.shields.io/github/last-commit/cschuijt/dotagem)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/cschuijt/dotagem)
![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/cschuijt/dotagem/latest)


![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/cschuijt/dotagem)
![GitHub repo size](https://img.shields.io/github/repo-size/cschuijt/dotagem)

---

### 🔍 What's this?
This is a Telegram bot that tracks users' Steam IDs so it can fetch their
recent games, stats and other game data, then display it through inline queries
or in group chats.

### 🌍 Is it live?
Yes! You can interact with it on Telegram at [@dotagem_bot](https://t.me/dotagem_bot)
or go to the homepage at [Dotagem.net](https://dotagem.net).

### 📊 Where does the data come from?
The data is fetched from [OpenDota](https://opendota.com), through their [API](https://docs.opendota.com).

### 😱 I've got a feature request/I've found a bug!
Feel free to open an [issue](https://github.com/cschuijt/dotagem/issues) here and I'll take a look! Or if you're a Ruby enjoyer like me, feel free to fork the repo and try your hand at doing it yourself. A little further down in this readme is information to help you get set up.

---

### 👨‍🎓 Skills I honed by working on this
I want to put this project in a portfolio on the long term, so I've tried to branch
out and make it as feature complete as possible. List of things of note, if you
ask me:

* App features:
  * Fetching data from an external JSON API, organizing endpoints, normalizing data
  * Caching large datasets in Redis so only one API call is required
  * Monolith design: app serves both Telegram bot API requests and web requests without the need for containers or multi-server deploys
* DevOps features:
  * Testing suite for all chat commands, complete with factories and mocks for API data
  * CI and branch protection to ensure the main branch always passes tests
  * Continuous deployment: tagging a new version will automatically deploy to server
  * Modifying the default setup for `rails s` in development to be able to test all HTTPS-dependent Telegram features, without the need to install Nginx
* Server features
  * Passenger + Nginx, with the app code living under a non-sudo user account
  * Strict HTTPS with auto-renewing certificates
  * Capistrano ensures the server is only updated on successful deploy and rollbacks are always possible

---

### ⚙ Technical information

#### Requirements
* Ruby 3.1.2
* Postgresql (14+, though swapping out for another database should be possible)
* Redis
* Authbind (if you want to be able to log in with Telegram on the dev server, see below)
* Foreman (for running the Procfile that starts all parts of the bot at once in development)

#### Install process
* Fork/Clone the repo
* `bundle` to install gems
* Delete `config/credentials.yml.enc` and `config/credentials`, because my credentials aren't your credentials
* Run `rails credentials:edit` to generate a new master key, then fill in the other secrets using `config/credentials.yml.example` as a guide
* `rails db:setup` to load the database schema and seed the tables with constant data
* Ensure that `authbind` to port 433 can be used, or change the line in `Procfile.dev`

#### Setup for Telegram
To test the Telegram end of things, I recommend getting a separate bot token for development. To be able to test advanced features (one-click signing in, inline queries) you will need to configure the bot as follows:
* `Bot settings -> Inline mode` should be on.
* `Bot settings -> Domain` should be `127.0.0.1`.
This is also why Authbind is required: if the webserver is not running HTTPS, Telegram will not provide an auth hash. And if you do not connect to it over 127.0.0.1, you will get invalid domain errors.

For your convenience, the list of commands I pass to BotFather is also available in the repo as `bot_command_list.txt`.

#### Development process
* **For bot work:** `rails telegram:bot:poller` to run the bot poller. I prefer not to include it in Foreman, because Puma doesn't handle hard crashes very well, and the poller will just die when it encounters a syntax error.
* **For web/frontend work:** `bin/dev` to run Puma and Tailwind-builder in one window. They both live refresh, so you shouldn't need to restart them unless you make config changes.
* Make your changes
* `rspec` to run the test suite
* Commit, push and submit a pull request!

### 👩‍💻 Under the hood
* The bot runs on Rails, with the Telegram part acting as middleware. The server is set up as a monolith. Exporting components should be possible too (database, redis) but it's written with the intention to keep everything in one place.
* To be able to juggle all the bot's commands, a global controller handles the initial request, then tries the sub-controllers one by one until one of them handles the message. This strikes a good balance in terms of spreading the code across multiple files, at the expense of invoking each subsequent controller until the right one is found.
* The OpenDota API is not JSON-api compliant, so we interact with it through [HTTParty](https://github.com/jnunemaker/httparty), then use database-less models to normalize the data we get back. This way, our controllers/the chatbot code will never have to touch the API directly, the heavy lifting is handled in the model and API files. To see how the API endpoints work under the hood, check out the `app/apis` directory.
* Signing in through Telegram and Steam is handled by OmniAuth, with a few small changes. By default, OmniAuth in development throws an exception when authentication fails. To ensure that you can follow login-links from Telegram to your site in development, that behavior is overridden with a redirect to root.
* The test suite should only query OpenDota once, to seed the database with constants at the very start. The actual tests should have their API calls stubbed out and replaced with factory data.
* Since Telegram requires our bot to run over HTTPS, Authbind and related setup is required. I've bundled my self-signed certificates with the bot in `config/certs`. If you use a browser from the Chrome family and want to avoid constant security warnings, there's a flag called "Allow invalid certificates for resources loaded from localhost" to suppress them.
