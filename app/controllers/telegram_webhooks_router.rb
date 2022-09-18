class TelegramWebhooksRouter < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include LoginUrl
  include ErrorHandling
  rescue_from StandardError, with: :error_out

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
    # Update the user's details if we can
    if update["message"]
      from = update["message"]["from"]
    elsif update["inline_query"]
      from = update["inline_query"]["from"]
    elsif update["callback_query"]
      from = update["callback_query"]["from"]
    end

    if defined?(from) && from && User.find_by(telegram_id: from["id"])
      user = User.find_by(telegram_id: from["id"])
      user.telegram_username = from["username"].downcase
      if from["last_name"]
        user.telegram_name = [from["first_name"], from["last_name"]].join(" ")
      else
        user.telegram_name = from["first_name"]
      end

      if User.where(telegram_username: user.telegram_username).any?
        User.where(telegram_username: user.telegram_username).each do |u|
          unless user == u
            u.telegram_username = "[#{u.telegram_id}]"
            u.save
          end
        end
      end
      
      user.save
    end

    catch :filtered do
      result = nil
      
      telegram_controllers.each do |controller|
        result = controller.dispatch(bot, update) if result.nil?
        break unless result.nil?
      end
      
      super if result.nil?
    end
  end

  def action_missing(*)
    respond_with :message, text:
                 "I don't know how to handle that command, sorry!" 
  end

  # Situations to handle:
  # Someone joins a chat the bot is in and gets an introduction
  def my_chat_member(*)
    if update["my_chat_member"]["new_chat_member"]
      respond_with :message,
      text: "Hello! I can fetch your Dota 2 match data and statistics " +
      "and display them in chats.\n" +
      "\nTo let me show your stats, I will need to know which Steam account " +
      "belongs to which Telegram account. If you want to use my commands, you " +
      "need to log in with the button below and complete your registration.",
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

  def message(*)
    catch(:it_was_me_all_along) do
      if update["message"]["new_chat_member"]
        throw(:it_was_me_all_along) if update["message"]["new_chat_member"]["username"] == bot.username

        unless User.find_by(telegram_id: update["message"]["new_chat_member"]["id"]) &&
               User.find_by(telegram_id: update["message"]["new_chat_member"]["id"]).steam_registered?
          respond_with :message, text: "Welcome! I can fetch your Dota 2 match data" +
          " and statistics and display them in this chat. If that sounds interesting, " +
          "use the button below to log in with your Steam account and get started.",
          reply_markup: {inline_keyboard: [
            [{
              text: "Log In",
              login_url: {url: login_callback_url}
            }]
          ]}
        end
      elsif from["id"] == chat["id"]
        respond_with :message, text: "I don't know how to handle that command, sorry!" 
      end
    end
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
