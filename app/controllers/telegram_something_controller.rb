class TelegramSomethingController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  def what!(*)
    respond_with :message, text: "xd!"
  end

  def something!(*)
    respond_with :message, text: "lmao!"
  end
end
