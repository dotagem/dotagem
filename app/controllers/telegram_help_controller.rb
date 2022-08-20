class TelegramHelpController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  # Generic help commands

  def commands!(*)
    respond_with :message, text: "You can find a list of commands somewhere or something I dunno"
  end

  def help!(*)
    respond_with :message, text: "Help is not available yet, hold on!"
  end
end
