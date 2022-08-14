class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  def start!(*)
    respond_with :message, text: "Hello!"
  end

  def help!(*)
    respond_with :message, text: "Hi there!"
  end
end
