class TelegramBotController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  include LoginUrl
  include ErrorHandling

  include BotComponents::HelpCommands
  include BotComponents::HeroCommands
  include BotComponents::InlineQueries
  include BotComponents::MatchCommands
  include BotComponents::PlayerCommands
  include BotComponents::UserCommands

  before_action :update_user_details

  rescue_from StandardError, with: :error_out

  def action_missing(*)
    raise Telegram::Bot::UnknownCommand
  end

  # For buttons that aren't supposed to do anything
  def nothing_callback_query(*)
    answer_callback_query ""
    return false
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
            url: "https://t.me/#{bot.username}?start=login"
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
              url: "https://t.me/#{bot.username}?start=login"
            }]
          ]}
        end
      elsif from["id"] == chat["id"]
        # We are in a DM with this user and should tell them we don't understand
        # the command they are trying to run/
        raise Telegram::Bot::UnknownCommand
      end
    end
  end

  # Do nothing when a channel message gets posted or edited
  def channel_post(*)
    true
  end

  def edited_channel_post(*)
    true
  end

  private

  def update_user_details(*)
    # Update the user's details if we can
    if update["message"]
      from = update["message"]["from"]
    elsif update["inline_query"]
      from = update["inline_query"]["from"]
    elsif update["callback_query"]
      from = update["callback_query"]["from"]
    end

    # Ensure automatic user saving is skipped in tests with minimal user data
    if defined?(from) && defined?(from["id"]) && !(from["username"].nil?) && from["username"] != bot.username
      user = User.find_or_create_by(telegram_id: from["id"])
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
            u.save!
          end
        end
      end

      user.save!
    end
  end

  # def session_key
  #   if update['message']
  #     chat_id = update['message']['chat']['id']
  #     message_id = update['message']['message_id']
  #   elsif update['callback_query']
  #     chat_id = update['callback_query']['message']['chat']['id']
  #     message_id = update['callback_query']['message']['message_id']
  #   else
  #     super
  #   end

  #   raise StandardError unless chat_id && message_id

  #   "#{bot.username}:#{chat_id}:#{message_id}"
  # end
end
