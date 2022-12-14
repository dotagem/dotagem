class TelegramUsersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include TelegramHelper
  include LoginUrl
  include ErrorHandling
  rescue_from StandardError, with: :error_out
  # Mostly for making a signin button to the site
  # if you're looking for player data commands, check TelegramPlayersController

  def login!(*)
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
                "log in or go to #{Rails.application.credentials.base_url} " +
                "and log in there."
      respond_with :message,
        text: message,
        reply_markup: {
          inline_keyboard: [web_button]
        }
    else
      if update["message"]["chat"]["type"] == "private"
        save_context :login_from_message
        message = "To use this bot, you need to log in with both Steam and " +
                  "Telegram. To complete your registration, you have two options:" +
                  "\n\na) Use the button below to log in with Steam via the website, or\n" +
                  "b) Send me a message with a link to your Steam profile and " +
                  "complete your registration that way."
        respond_with :message,
          text: message,
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
              "below or go to #{Rails.application.credentials.base_url} " +
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
