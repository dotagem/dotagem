class TelegramWebhooksRouter < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  # Dispatch the message to each Telegram controller,
  # until one of them handles it. If none handle it, super
  # to run the global action_missing here in the router.
  #
  # Controller naming convention is telegram_*_controller.rb
  # And should live in the app/controllers directory.
  #
  # To make sure this works, do not redefine action_missing
  # in other controllers, or at least make sure it returns nil!
  # Monkey patching action_missing will 'catch' all
  # non-matching commands in your controller, breaking others.
  def self.dispatch(bot, update)
    result = nil
    
    telegram_controllers.each do |controller|
      result = controller.dispatch(bot, update) if result.nil?
      break unless result.nil?
    end

    super if result.nil?
  end

  def action_missing(*)
    respond_with :message, text:
                 "I don't know how to handle that command, sorry!" 
  end

  private

  # Build a list of telegram bot controllers
  def self.telegram_controllers
    list = []
    Dir[Rails.root.join('app/controllers/telegram_*_controller.rb')].each do |c|
      list << File.basename(c, ".rb").camelize.constantize 
    end
    list
  end
end
