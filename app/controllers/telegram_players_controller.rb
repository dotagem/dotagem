class TelegramPlayersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::TextHelper

  include MatchMessages
  include AliasHandling
  include Pagination
  include HeroPlayerOptions
  include ButtonProcStrings
  include MessageSession
  include OpendotaHelper

  before_action :logged_in_or_mentioning_player, only: [:matches!,   :recents!,
                                                        :winrate!,   :wl!,
                                                        :rank!,      :profile!,
                                                        :peers!,     :heroes!,
                                                        :lastmatch!]

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
        message_session[:player] = @player.id
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

    edit_message :text, text: build_matches_header(
      session[:items], session[:options]
    )
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_paginated_buttons(
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
    
    # These need to be nil or unintended buttons show up
    session[:hero_mode] = nil
    session[:hero_sort] = nil

    edit_message :text, text: build_matches_header(
      session[:items], session[:options]
    )
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_paginated_buttons(
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

  def build_short_match_message(m)
    message = []
    message << "Last match for #{@player.telegram_username}"
    message << ""
    message << "Hero: #{Hero.find_by(hero_id: m.hero_id).localized_name}"
    message << "Result: #{m.wl} in #{m.duration / 60} mins"
    message << "Played #{time_ago_in_words(Time.at(m.start_time))} ago\n"
    message << "KDA: #{m.kills}/#{m.deaths}/#{m.assists}, LH/D: #{m.last_hits}/#{m.denies}"
    message << "Mode: #{GameMode.find_by(mode_id: m.game_mode).localized_name}, " +
               "#{LobbyType.find_by(lobby_id: m.lobby_type).localized_name}, " +
               "#{Region.find_by(region_id: m.region).localized_name}"
    message << "Avg. rank: #{format_rank(m.average_rank)}, party of #{m.party_size}"

    message.join("\n")
  end

  def build_win_loss_message(data, options=nil)
    message = ["Winrate for #{@player.telegram_username}:"]
    if options
      message << build_options_message(options)
    end
    message << "#{pluralize(data["win"], "win")}, #{pluralize(data["lose"], "loss")}"
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
end
