module BotComponents::UserCommands
  extend ActiveSupport::Concern

  include Telegram::Bot::UpdatesController::MessageContext
  include TelegramHelper
  include LoginUrl
  # Mostly for making a signin button to the site
  # if you're looking for player data commands, check PlayerCommands

  def login!(*args)
    web_button = [
      {
        text: "Log In (website)",
        login_url: {url: login_callback_url}
      }
    ]

    message_button = [
      {
        text: "Log In (message)",
        url: "https://t.me/#{bot.username}?start=login"
      }
    ]

    current_user = User.find_by(telegram_id: from["id"])
    if current_user && current_user.steam_registered?
      message = "Your registration is complete and you can now use the bot! " +
                "If you want to unlink your account, use the button below to " +
                "log in or go to #{ENV['BASE_URL']} " +
                "and log in there."
      respond_with :message,
        text: message,
        reply_markup: {
          inline_keyboard: [web_button]
        }
    else
      if update["message"]["chat"]["type"] == "private"
        if args.count > 0
          login_from_message(args[0])
          return
        end

        message = "To use this bot, you need to log in with both Steam and " +
                  "Telegram. To complete your registration, you have two options:" +
                  "\n\na) Use the button below to log in with Steam via the website, or\n" +
                  "b) Send me this command again with a link to your Steam profile " +
                  "(<code>/login https://steamcommunity.com/id/tradeless</code>`) and " +
                  "complete your registration that way."
        respond_with :message,
          text: message,
          parse_mode: "html",
          reply_markup: {
          inline_keyboard: [web_button]
        }
      else
        message = "To use this bot, you need to log in with both Steam and " +
        "Telegram. To complete your registration, open a PM with " +
        "me using the button below or go to the website and log in " +
        "with Steam there."
        respond_with :message,
          text: message,
          reply_markup: {
            inline_keyboard: [web_button, message_button]
          }
      end
    end
  end

  alias_method :log_in!,  :login!
  alias_method :signin!,  :login!
  alias_method :sign_in!, :login!

  def account!(*)

    message = "To connect, disconnect or delete your account, use the button " +
              "below or go to #{ENV['BASE_URL']} " +
              "and log in."
    respond_with  :message, text: message,
      reply_markup: {
        inline_keyboard: [
          [{
            text: "Log In",
            login_url: {url: login_callback_url}
          }]
        ]
      }
  end
end
