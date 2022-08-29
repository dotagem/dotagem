class TelegramUsersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include TelegramHelper
  # Mostly for making a signin button to the site
  # if you're looking for player data commands, check TelegramPlayersController

  def login!(*)
    current_user = User.find_by(telegram_id: from["id"])
    if current_user && current_user.steam_registered?
      message = "Your registration is complete and you can now use the bot! " +
                "If you want to unlink your account, use the button below to " +
                "log in or go to #{Rails.application.credentials.base_url} " +
                "and log in there."
    else
      message = "To use this bot, you need to log in with both Steam and " +
                "Telegram. To complete your registration, use the button " +
                "below to log in instantly, or go to " +
                "#{Rails.application.credentials.base_url} and log in there."
    end
    respond_with :message,  text: message,
                            reply_markup: {
                              inline_keyboard: [
                                [{
                                  text: "Log In",
                                  login_url: {url: login_callback_url}
                                }]
                              ]
                            }
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

  private

  def login_callback_url
    "#{Rails.application.credentials.base_url}/auth/telegram/callback"
  end
end
