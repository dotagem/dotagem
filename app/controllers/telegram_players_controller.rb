class TelegramPlayersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  include MatchMessages
  include AliasHandling
  include Pagination

  before_action :logged_in_or_mentioning_player, only: [:matches!, :recents!,
                                                        :winrate!, :wl!]

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
        # We can't build a normal message yet so we throw out right now
        throw(:filtered)
      else
        @matches = @player.matches(options)
      end
    else
      @matches = @player.matches
    end

    result = respond_with :message, text: build_matches_header(@matches, options),
             reply_markup: {inline_keyboard: build_paginated_buttons(@matches)}
    message_session(result['result']['message_id'])
    message_session[:items] = @matches
    message_session[:page] = 1
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

  private

  def build_win_loss_message(data, options=nil)
    message = ["Winrate:"]
    if options
      message << build_options_message(options)
    end
    message << "#{data["win"]} wins, #{data["lose"]} losses"
    message.join("\n")
  end

  def build_and_validate_options(args)
    delimiters = ["as", "with", "against", "and"]

    # Prepare the array
    args.each do |a|
      a.downcase.tr("@", "")
    end
    args.delete_at(0) if User.find_by(telegram_username: args[0])
    # Split it up
    chunks = args.chunk { |v| v.in?(delimiters) }.to_a
    # Array must start with a true chunk and end with a false one
    # It's okay to insert an invalid value here, we just don't want to
    # throw an exception at this stage
    chunks.unshift [true, ["as"]] if chunks.first[0] == false
    chunks.push    [false, [""] ] if chunks.last[0]  == true
    # Build the array
    options = []
    chunks.each_with_index do |c, i|
      if c[0] == true
        options << { mode: c[1].join(" "), value: chunks[i+1][1].join(" ") }
      end
    end

    return false if options.first[:mode] == "and"
    options.each_with_index do |o, i|
      o[:mode] = o[:mode].split(" ").last
      if o[:mode] == "and"
        o[:mode] = options[i - 1][:mode]
      end
    end

    # Validation time!
    return false if options.count { |o| o[:mode] == "as" } > 1
    return false if options.count > 10
    options.each do |o|
      return false unless o[:mode].in?(delimiters)
      return false if     o[:value].blank?
      return false unless hero_or_player(o[:value])
      return false if     (o[:mode] == "as" || o[:mode] == "against") &&
                          User.find_by(telegram_username: o[:value])
    end

    # Construct query hash
    query = {}
    options.each do |o|
      if User.find_by(telegram_username: o[:value])
        query[:included_account_id] ||= []
        query[:included_account_id] << User.find_by(telegram_username: o[:value]).steam_id
      else # Alias
        if o[:mode] == "as"
          query[:hero_id] = resolve_alias(o[:value])
        elsif o[:mode] == "with"
          query[:with_hero_id] ||= []
          query[:with_hero_id] << resolve_alias(o[:value])
        else # mode == "against"
          query[:against_hero_id] ||= []
          query[:against_hero_id] << resolve_alias(o[:value])
        end
      end
    end
    return query
  end

  def clean_up_options(options)
    if Hash === options[:hero_id] && options[:hero_id][:result]
      options[:hero_id] = options[:hero_id][:result]
    end
    if options[:with_hero_id]
      options[:with_hero_id].each_with_index do |h, i|
        if Hash === h && h[:result]
          options[:with_hero_id][i] = h[:result]
        end
      end
    end
    if options[:against_hero_id]
      options[:against_hero_id].each_with_index do |h, i|
        if Hash === h && h[:result]
          options[:against_hero_id][i] = h[:result]
        end
      end
    end
    options
  end

  def hero_or_player(string)
    Alias.find_by(name: string) || User.find_by(telegram_username: string)
  end

  def resolve_alias(string)
    aliases = Alias.where(name: string)
    if aliases.any?
      if aliases.count == 1
        aliases.first.hero.hero_id
      else
        # We'll find these later
        {query: string}
      end
    end
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
