class TelegramHelpController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include LoginUrl
  # Generic help commands

  def help!(*)
    respond_with :message,
    text: "Click the buttons below for the help page, and a list of commands!",
    reply_markup: { inline_keyboard: [
      [
        {text: "Help", url: "#{Rails.application.credentials.base_url}/help"}
      ],
      [
        {text: "Commands", url: "#{Rails.application.credentials.base_url}/commands"}
      ]
    ]}
  end

  def commands!(*)
    respond_with :message,
    text: "Click the button below for a list of commands!",
    reply_markup: { inline_keyboard: [
      [
        {text: "Commands", url: "#{Rails.application.credentials.base_url}/commands"}
      ]
    ]}
  end

  # For buttons that aren't supposed to do anything
  def nothing_callback_query(*)
    answer_callback_query ""
    return false
  end

  def start!(*)
    respond_with :message,
    text: "Hello! I can fetch your Dota 2 match data and statistics " +
    "and display them in chats. I am most useful when added to group chats.\n" +
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
