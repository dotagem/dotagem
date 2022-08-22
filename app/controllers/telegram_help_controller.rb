class TelegramHelpController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  # Generic help commands

  def commands!(*)
    respond_with :message, text: "You can find a list of commands somewhere or something I dunno"
  end

  def help!(*)
    respond_with :message, text: "Help is not available yet, hold on!"
  end

  # For buttons that aren't supposed to do anything
  def nothing_callback_query(*)
    answer_callback_query ""
    return false
  end
end
