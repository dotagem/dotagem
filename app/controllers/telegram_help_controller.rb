class TelegramHelpController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include LoginUrl
  
  include ErrorHandling
  rescue_from StandardError, with: :error_out
  
  require 'steam_id'
  
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
    website_button = [
      {
        text: "Log In (website)",
        login_url: {url: login_callback_url}
      }
    ]

    message_button = [
      {
        text: "Log In (message)",
        url: "https://t.me/#{bot.username}?start=login"
      }
    ]

    base_message = "Hello! I can fetch your Dota 2 match data and statistics " +
    "and display them in chats. I am most useful when added to group chats.\n"

    if update["message"]["chat"]["type"] == "private"
      save_context :login_from_message
      if User.find_by(telegram_id: from["id"]).steam_registered?
        respond_with :message,
        text: base_message + "\nYou are already signed in and ready to use the " +
        "bot's commands! If you want to edit or remove your registration, " +
        "you can do so on the site with the button below. You can also send me" +
        " a link to a Steam profile if you want to change your Steam account.",
        reply_markup: {
          inline_keyboard: [website_button]
        }
      else
        respond_with :message,
        text: base_message +
        "\nTo let me show your stats, you have two options for signing in: \n\n" +
        "a) Use the button below this message and log in with Steam through the site, or\n" +
        "b) Send a message with a link to your Steam profile!",
        reply_markup: {
          inline_keyboard: [website_button]
        }
      end
    else
      respond_with :message,
      text: base_message +
      "\nTo let me show your stats, I will need to know which Steam account " +
      "belongs to which Telegram account. If you want to use my commands, you " +
      "need to log in with the button below and complete your registration on " +
      "the site, or use the other button and complete it in chat.",
      reply_markup: {
        inline_keyboard: [website_button, message_button]
      }
    end
  end

  def login_from_message(*words)
    try = words[0]
    begin
      r = SteamID.from_string(try, api_key: Rails.application.credentials.steam.token)
      save_context :login_from_message
      respond_with :message, text: "I've found #{r.profile_url} \n" +
      "If you want to register this account, press the button below. If not, try " +
      "sending me a different steam ID.",
      reply_markup: {
        inline_keyboard: [[
          {
            text: "Register this account",
            callback_data: "register:#{r.account_id}"
          }
        ]]
      }
    rescue ArgumentError
      save_context :login_from_message
      respond_with :message, text: "I can't find that account, sorry! Please try again.\n" +
      "You can send me a link to your profile, a steam ID number or a vanity URL."
    end
  end

  def register_callback_query(account_id)
    u = User.find_by(telegram_id: from["id"])
    steam = SteamID.from_string(account_id)
    community = SteamCondenser::Community::SteamId.new(steam.id_64)
    removed = nil

    if User.where(steam_id64: steam.id_64).any?
      User.where(steam_id64: steam.id_64).each do |user|
        unless user == u
          user.steam_id64     = nil
          user.steam_id       = nil
          user.steam_nickname = nil
          user.steam_avatar   = nil
          user.steam_url      = nil

          removed = true
          user.save!
        end
      end
    end

    u.steam_id64     = steam.id_64
    u.steam_id       = steam.account_id
    u.steam_nickname = community.nickname
    u.steam_avatar   = community.full_avatar_url
    u.steam_url      = steam.profile_url

    u.save!

    message = "Your registration is now complete and you can use " +
    "the bot's commands! If you want to edit or remove your registration, use " +
    "<code>/account</code> and go to the website."

    if removed
      message << "\n\nAnother account in the database had this Steam account " +
      "registered, their registration has been removed."
    end

    bot.send_message(
      chat_id: update["callback_query"]["message"]["chat"]["id"],
      text: message,
      parse_mode: "html"
    )
    answer_callback_query ""
  end
end
