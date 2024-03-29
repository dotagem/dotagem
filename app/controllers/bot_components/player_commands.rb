module BotComponents::PlayerCommands
  extend ActiveSupport::Concern

  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::TextHelper

  include MatchesMessages
  include AliasHandling
  include Pagination
  include HeroPlayerOptions
  include ButtonProcStrings
  include MessageSession
  include OpendotaHelper
  include MatchMessages

  included do
    before_action :logged_in_or_mentioning_player, only: [:rank!,      :profile!,
                                                          :peers!,     :heroes!,
                                                          :lastmatch!]

    before_action :permissive_logged_in_or_mentioning_player, only: [:matches!,
                                                                    :recents!,
                                                                    :winrate!,
                                                                    :wl!]
  end

  def matches!(*args)
    options = nil
    if args.any?
      options = build_and_validate_options(args)
      if options == false
        respond_with :message, text: "Invalid input!"
        return
      end
      options.extend Hashie::Extensions::DeepLocate

      unclear = options.deep_locate -> (key, _, object) { key == :query && !object[:result] }
      if unclear.any?
        intention = "matches"
        result = respond_with :message, text: build_alias_resolution_message(options, intention),
                 reply_markup: {inline_keyboard: build_alias_resolution_keyboard(options)}
        message_session(result['result']['message_id'])
        message_session[:options] = options
        message_session[:player] = @player.id
        message_session[:intention] = intention
        message_session[:button] = match_button_proc_string
        # We can't build a normal message yet so we throw out right now
        return
      else
        @matches = @player.matches(options)
      end
    else
      @matches = @player.matches
    end

    result = respond_with :message, text: build_matches_header(@matches, options),
             reply_markup: {inline_keyboard: build_paginated_url_buttons(@matches, match_button_proc_string)}
    message_session(result['result']['message_id'])
    message_session[:items] = @matches
    message_session[:intention] = "matches"
    message_session[:page] = 1
    message_session[:button] = match_button_proc_string
    message_session[:player] = @player.id
  end

  alias_method :recents!, :matches!

  def matches_with_player_callback_query(player_id)
    player_id = player_id.to_i
    @player = User.find(session[:player])
    session[:options] = {included_account_id: [player_id]}

    session[:items] = @player.matches(session[:options])
    session[:page] = 1
    session[:button] = match_button_proc_string
    session[:intention] = "matches"

    edit_message :text, text: build_matches_header(
      session[:items], session[:options]
    )
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_paginated_url_buttons(
        session[:items], session[:button], session[:page]
      )
    }

    answer_callback_query ""
  end

  def matches_hero_callback_query(hero_id)
    hero_id = hero_id.to_i
    options = {}


    case session[:hero_mode]
    when "with"
      options[:with_hero_id] = [hero_id]
    when "against"
      options[:against_hero_id] = [hero_id]
    else
      # Assume default if hero_mode somehow isn't given
      options[:hero_id] = hero_id
    end

    @player = User.find(session[:player])
    session[:options] = options
    session[:items] = @player.matches(session[:options])
    session[:page] = 1
    session[:button] = match_button_proc_string
    session[:intention] = "matches"

    # These need to be nil or unintended buttons show up
    session[:hero_mode] = nil
    session[:hero_sort] = nil

    edit_message :text, text: build_matches_header(
      session[:items], session[:options]
    )
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_paginated_url_buttons(
        session[:items], session[:button], session[:page]
      )
    }

    answer_callback_query ""
  end

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
        message_session[:player] = @player.id
        message_session[:intention] = intention
        # We can't build a normal message yet so we throw out right now
        return
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
    sort = "games"

    if data.any?
      data = sort_peers_by_mode(data, sort)

      if data.count > 1
        keyboard =  [build_peer_sort_buttons(sort)]
        keyboard += build_paginated_buttons(data, peer_button_proc_string)
      else
        keyboard = build_paginated_buttons(data, peer_button_proc_string)
      end
    else
      keyboard = []
    end

    result = respond_with :message,
      text: "Peers of #{@player.telegram_username}\n#{pluralize(data.count, "result")}",
      reply_markup: {inline_keyboard: keyboard}
    message_session(result['result']['message_id'])
    message_session[:items] = data
    message_session[:player] = @player.id
    message_session[:page] = 1
    message_session[:peer_sort] = sort
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
    message_session[:player]    = @player.id
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

  def lastmatch!(*)
    @match = @player.matches(limit: 1).first
    respond_with :message, text: build_short_match_message(@match), reply_markup: {
      inline_keyboard: [[{
        text: "Match details on OpenDota",
        url: "https://opendota.com/matches/#{@match.match_id}"
      }]]
    }
  end

  private

  def build_win_loss_message(data, options=nil)
    message = ["Winrate for #{@player.telegram_username}:"]
    if options
      message << build_options_message(options)
    end
    message << "#{pluralize(data["win"], "win")}, #{pluralize(data["lose"], "loss")}"
    message << build_percentage_line(data["win"], data["lose"])
    message.join("\n")
  end

  def build_percentage_line(w, l)
    if w + l == 0
      "0%"
    else
      p = (w.to_f / (w + l) * 100).round(2)
      "#{p}%"
    end
  end

  def logged_in_or_mentioning_player
    _, args = Telegram::Bot::UpdatesController::Commands.command_from_text(payload['text'], bot_username)
    if args.any?
      args[0] = args[0].tr("@", "")
      @player = User.find_by(telegram_username: args[0].downcase)
      if @player.nil?
        respond_with :message, text: "I don't know that user, sorry! They may not be" +
        " registered yet."
        throw :abort
      elsif !@player.steam_registered?
        respond_with :message, text: "That user has not signed in with Steam yet! " +
        "Once they sign in, their data will become available."
        throw :abort
      end
    else
      @player = User.find_by(telegram_id: from["id"])
      if @player.nil? || !(@player.steam_registered?)
        respond_with :message, text: "You need to register before you can use that command!" +
        " Use the button below to open a chat with me and sign in with Steam.",
        reply_markup: {
          inline_keyboard: [[
            { text: "Log In", url: "https://t.me/#{bot.username}?start=login" }
          ]]
        }
        throw :abort
      end
    end
  end

  def permissive_logged_in_or_mentioning_player
    _, args = Telegram::Bot::UpdatesController::Commands.command_from_text(payload['text'], bot_username)
    if args.any?
      args[0] = args[0].tr("@", "")
      @player = User.find_by(telegram_username: args[0].downcase)
    end
    @player ||= User.find_by(telegram_id: from["id"])

    if @player.nil? || !(@player.steam_registered?)
      respond_with :message, text: "You need to register before you can use that command!" +
        " If you tried to tag another user, they may not be registered yet.\n\n" +
        "Use the button below to open a chat with me and sign in with Steam.",
        reply_markup: {
          inline_keyboard: [[
            { text: "Log In", url: "https://t.me/#{bot.username}?start=login" }
          ]]
        }
      throw :abort
    end
  end
end
