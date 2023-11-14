# 💎 Gem of True Sight
##### A Telegram bot that fetches and displays stats and Dota 2 data

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
Feel free to open an [issue](https://github.com/dotagem/dotagem/issues) here and I'll take a look! Or if you're a Ruby enjoyer like me, feel free to fork the repo and try your hand at doing it yourself. A little further down in this readme is information to help you get set up.

---

### 👨‍🎓 Skills I honed by working on this
I want to put this project in a portfolio on the long term, so I've tried to branch
out and make it as feature complete as possible. List of things of note, if you
ask me:

* App features:
  * Fetching data from an external JSON API, organizing endpoints, normalizing data and finally presenting it in a messaging app format
  * Caching large datasets in Redis so only one API call is required when paging through the response
* DevOps features:
  * Testing suite for all chat commands, complete with factories and mocks for API data
  * CI to ensure the main branch always passes tests
  * Continuous deployment: pushing to main will automatically deploy to the server

---

### ⚙ Technical information

By far the easiest way to get set up is to use Docker. Copy the `.env.example` file
to `.env` and fill in your API keys and other variables, run `docker compose up -d`
and then the main page should appear on `localhost:3000`.

To make Telegram messages and sign-in work, you have two options. For development,
I recommend using the poller by opening a terminal in the app container and running
`bin/rails telegram:bot:poller`. This will handle any incoming messages. In production,
using webhooks scales better. Execute `rails telegram:bot:set_webhook` and Telegram
will reach out to the app whenever a message comes in.

Currently missing is an easy way to test the Telegram features that require HTTPS in development,
like webhooks and OAuth callbacks. There was an authbind solution, but since converting the
app to Docker I've not felt the need to make it work anymore.

For your convenience, the list of commands I pass to BotFather is also available in the repo as `bot_command_list.txt`.

### 👩‍💻 Under the hood
* The bot runs on Rails, with the Telegram part acting as middleware. The server is set up as a monolith. Exporting components should be possible too (database, redis) but it's written with the intention to keep everything in one place.
* A single `TelegramBotController` handles all the Telegram webhooks. To keep the file from becoming absolutely bloated, the commands and hooks themselves are divided across different ActiveRecord concerns and included in this controller. The current layout needs some love still, but this way, each command at least has a logical home.
* We interact with the OpenDota API through [HTTParty](https://github.com/jnunemaker/httparty), then use database-less models to normalize the data we get back. This way, our controllers/the chatbot code will never have to touch the API directly, the heavy lifting is handled in the model and API files. To see how the API endpoints work under the hood, check out the `app/apis` directory.
* Signing in through Telegram and Steam is handled by OmniAuth, with a few small changes. By default, OmniAuth in development throws an exception when authentication fails. To ensure that you can follow login-links from Telegram to your site in development, that behavior is overridden with a redirect to root.
* The test suite should only query OpenDota once, to seed the database with constants at the very start. The actual tests should have their API calls stubbed out and replaced with factory data.
