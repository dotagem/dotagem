# Gem of True Sight
##### A Telegram bot that fetches and displays stats and Dota 2 data
![RSpec](https://github.com/cschuijt/dotagem/actions/workflows/rspec.yml/badge.svg)

---

### What's this?
This is a Telegram bot that tracks users' Steam IDs so it can fetch their
recent games, stats and other game data, then display it through inline queries
or in group chats.

### Where does the data come from?
The data is fetched from [OpenDota](https://opendota.com), through their [API](https://docs.opendota.com).

### Is it done yet?
Not nearly. Here's my incomplete checklist of doom:

- [x] Set up telegram-bot and make it talk to the Telegram bot API 💬
- [x] Set up HTTParty so we can talk to the OpenDota API 🌐
- [x] Make the data we get back from OpenDota quack like a Rails model 🦆
- [x] Fetch and cache constants from OpenDota so we don't need to bother the API for things like hero names 📃
- [x] Allow users to sign in through Steam and identify themselves 🔐
- [ ] Build match commands 📅
- [x] Build player commands 🤼
- [ ] Build hero commands ⚔
- [ ] Handle inline queries as well ⌨
- [x] Configure session storage so we can paginate and clarify on the fly ✅
- [ ] Make sure the bot performs over webhooks as well (dev environment uses the poller) ⚙
- [ ] Write tests for everything 🧪
- [x] Make an example credentials file 🔑
- [ ] Pretty up the sign-in frontend 💻

### Technical details and loosely related thoughts
* [Telegram-bot](https://github.com/telegram-bot-rb/telegram-bot) behaves as Rails middleware, so we run a Rails app with it installed. The only thing we use the web frontend for is logging in through Steam and for a landing page in case people browse to our site.
* The OpenDota API is not JSON-api compliant, so we interact with it through [HTTParty](https://github.com/jnunemaker/httparty), then use database-less models to normalize the data we get back. This way, our controllers/the chatbot code will never have to touch the API directly, the heavy lifting is handled in the model and API files.
* The API part of the app can be found in the `app/apis` directory, with each endpoint being its own file. Not all endpoints are implemented, but adding new ones into this structure is very straightforward. Since it lives in the app directory, Zeitwerk automatically loads them for you to include in your code elsewhere.
* To run the bot in a dev environment, you'll need two processes: run `rails telegram:bot:poller` in one window and `rails s` in another. If you don't run the poller, it won't be able to see and respond to chat messages. If you don't run the webserver, it won't be able to let you log in through Steam.
* Constants that are cached in the database have a class method called `refresh`, which will clear out the table and fetch new data from OpenDota, all in one atomic transaction. 
