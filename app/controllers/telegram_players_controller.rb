class TelegramPlayersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  include MatchMessages
  include AliasHandling
  include Pagination
  include HeroPlayerOptions
  include ButtonProcStrings

  before_action :logged_in_or_mentioning_player, only: [:matches!, :recents!,
                                                        :winrate!, :wl!,
                                                        :rank!,    :profile!,
                                                        :peers!,   :heroes!]

  def matches!(*args)
    options = nil
    if args.any?
      options = build_and_validate_options(args) 
      if options == false
        respond_with :message, text: "Invalid input!"
        throw(:filtered)
      end
      options.extend Hashie::Extensions::DeepLocate
      
      unclear = options.deep_locate -> (key, _, object) { key == :query && !object[:result] }
      if unclear.any?
        intention = "matches"
        result = respond_with :message, text: build_alias_resolution_message(options, intention),
                 reply_markup: {inline_keyboard: build_alias_resolution_keyboard(options)}
        message_session(result['result']['message_id'])
        message_session[:options] = options
        message_session[:player] = @player
        message_session[:intention] = intention
        message_session[:button] = match_button_proc_string
        # We can't build a normal message yet so we throw out right now
        throw(:filtered)
      else
        @matches = @player.matches(options)
      end
    else
      @matches = @player.matches
    end

    result = respond_with :message, text: build_matches_header(@matches, options),
             reply_markup: {inline_keyboard: build_paginated_buttons(@matches, match_button_proc_string)}
    message_session(result['result']['message_id'])
    message_session[:items] = @matches
    message_session[:page] = 1
    message_session[:button] = match_button_proc_string
  end

  alias_method :recents!, :matches!

  def winrate!(*args)
    if args.any?
      options = build_and_validate_options(args)
      if options == false
        respond_with :message, text: "Invalid input!"
        return false
      end
      options.extend Hashie::Extensions::DeepLocate
      
      unclear = options.deep_locate -> (key, _, object) { key == :query && !object[:result] }
      if unclear.any?
        intention = "wl"
        result = respond_with :message, text: build_alias_resolution_message(options, intention),
                 reply_markup: {inline_keyboard: build_alias_resolution_keyboard(options)}
        message_session(result['result']['message_id'])[:options] = options
        message_session[:player] = @player
        message_session[:intention] = intention
        # We can't build a normal message yet so we throw out right now
        throw(:filtered)
      else
        @data = @player.win_loss(options)
      end
    else
      @data = @player.win_loss
    end

    if args.any?
      message = build_win_loss_message(@data, options)
    else
      message = build_win_loss_message(@data)
    end
    
    reply_with :message, text: message
  end

  alias_method :wl!, :winrate!

  def peers!(*)
    data = @player.peers.select { |p| p.known? }
    result = respond_with :message,
      text: "Peers of #{@player.telegram_username}\n#{pluralize(data.count, "result")}",
      reply_markup: {inline_keyboard: build_paginated_buttons(data, peer_button_proc_string)}
    message_session(result['result']['message_id'])
    message_session[:items] = data
    message_session[:page] = 1
    message_session[:button] = peer_button_proc_string
  end

  def heroes!(*)
    items = @player.heroes
    message = "Heroes for #{@player.telegram_username}"

    # Dynamically assign this in the future maybe?
    hero_mode = "as"
    hero_sort = "games"

    keyboard = []
    keyboard << build_hero_mode_buttons(hero_mode)
    keyboard << build_hero_sort_buttons(hero_sort)
    keyboard = keyboard + build_paginated_buttons(items, hero_as_button_proc_string)

    result = respond_with :message, text: message, reply_markup: {
      inline_keyboard: keyboard
    }

    message_session(result['result']['message_id'])
    message_session[:items]     = items
    message_session[:page]      = 1
    message_session[:button]    = hero_as_button_proc_string
    message_session[:hero_mode] = hero_mode
    message_session[:hero_sort] = hero_sort
  end

  def rank!(*)
    respond_with :message, text: "@#{@player.telegram_username}'s rank is #{@player.rank}"
  end

  def profile!(*)
    respond_with :message, text: "#{@player.telegram_username}'s Steam profile is #{@player.steam_url}"
  end

  private

  def build_win_loss_message(data, options=nil)
    message = ["Winrate:"]
    if options
      message << build_options_message(options)
    end
    message << "#{data["win"]} wins, #{data["lose"]} losses"
    message.join("\n")
  end

  def logged_in_or_mentioning_player
    _, args = Telegram::Bot::UpdatesController::Commands.command_from_text(payload['text'], bot_username)
    args[0] = args[0].tr("@", "") if args.any?
    @player = User.find_by(telegram_username: args[0]) ||
              User.find_by(telegram_id: from["id"])
    if @player.nil?
      respond_with :message, text: "Can't find that user!"
      throw(:filtered)
    elsif @player.steam_registered? == false
      respond_with :message, text: "That user has not completed their registration!"
      throw(:filtered)
    end
  end

  protected

  def session_key
    # If we're in a callback query, associate default session with message ID
    if update['callback_query']
      "#{bot_username}:#{chat['id']}:#{update['callback_query']['message']['message_id']}"
    end
  end

  def message_session(message_id=nil)
    @_message_session ||= self.class.build_session(chat && message_id &&
                          "#{bot.username}:#{chat['id']}:#{message_id}")
  end

  def process_action(*)
    super
  ensure
    message_session.commit if @_message_session
  end
end
