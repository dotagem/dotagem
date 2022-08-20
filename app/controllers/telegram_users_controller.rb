class TelegramUsersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include TelegramHelper
  # Mostly for making a signin button to the site
  # if you're looking for player data commands, check TelegramPlayersController

  def login!(*)
    respond_with :message, text: "To sign in, click the button below:",
                          reply_markup: {
                            inline_keyboard: [
                              [
                                {
                                  text: "hi",
                                  login_url:
                                  {
                                    url: 'https://127.0.0.1/auth/telegram/callback',
                                  }
                                }
                              ]
                            ]
                          }
  end
end
