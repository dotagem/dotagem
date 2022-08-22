class TelegramPlayersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::DateHelper

  before_action :logged_in_or_mentioning_player, only: [:matches!, :winrate!, :wl!]

  PAGE_ITEMS = 5

  def matches!(*args)
    options = nil
    if args.any?
      options = build_and_validate_options(args) 
      @matches = @player.matches(options)
    else
      @matches = @player.matches
    end

    result = respond_with :message, text: build_matches_header(@matches, options),
             reply_markup: {inline_keyboard: build_matches_buttons(@matches)}
    
    message_session(result['result']['message_id'])[:matches] = @matches
    message_session[:page] = 1
  end

  alias_method :recents!, :matches!

  def pagination_callback_query(page)
    edit_message :reply_markup, reply_markup:
          {inline_keyboard: build_matches_buttons(session[:matches], page.to_i)}
    session[:page] = page
    answer_callback_query ""
  end

  def build_matches_header(matches, options=nil)
    message = ["Matches"]
    if options
      if options[:hero_id]
        message << "Playing as #{Hero.find_by(hero_id: options[:hero_id]).localized_name}"
      end
      if options[:included_account_id]
        accounts = []
        options[:included_account_id].each do |account|
          accounts << Player.find_by(steam_id3: account).telegram_username
        end
        message << "With players: #{accounts.join(", ")}"
      end

      if options[:with_hero_id]
        heroes = []
        options[:with_hero_id].each do |hero_id|
          heroes << Hero.find_by(hero_id: hero_id).localized_name
        end
        message << "Allied heroes: #{heroes.join(", ")}"
      end

      if options[:against_hero_id]
        heroes = []
        options[:against_hero_id].each do |hero_id|
          heroes << Hero.find_by(hero_id: hero_id).localized_name
        end
        message << "Enemy heroes: #{heroes.join(", ")}"
      end
    end
    message << "#{matches.count} results"
    message.join("\n")
  end

  def build_matches_buttons(matches, page=1)
    i = (page - 1) * PAGE_ITEMS
    subset = matches[i..i+PAGE_ITEMS-1]
    keyboard = []
    subset.each do |match|
      keyboard << [
        {
          text: match_button_text(match),
          callback_data: "match_detail:#{match.match_id}" 
        }
      ]
    end

    pages = matches.count / PAGE_ITEMS
    if (matches.count % PAGE_ITEMS) > 0
      pages = pages + 1
    end
    
    if pages > 1
      row  = []
      if page > 1
        if page > 2
          row << {
              text: "|<<",
              callback_data: "pagination:1"
          }
        end
        row << {
          text: "<",
          callback_data: "pagination:#{page-1}"
        }
      end
      row << {
        text: "#{page} / #{pages}",
        callback_data: "nothing:0"
      }
      if page < pages
        row << {
          text: ">",
          callback_data: "pagination:#{page+1}"
        }
        if page < pages - 1
          row << {
            text: ">>|",
            callback_data: "pagination:#{pages}"
          }
        end
      end
      keyboard << row
    end

    return keyboard
  end

  def match_button_text(m)
    duration = m.duration / 60
    "#{duration}min #{m.wl} #{m.rd} #{m.kills}/#{m.deaths}/#{m.assists} " +
    "#{Hero.find_by(hero_id: m.hero_id).localized_name} " +
    "#{time_ago_in_words(Time.at(m.start_time))} ago"
  end

  def winrate!(*args)
    if args.any?
      options = build_and_validate_options(args)
      if options == false
        respond_with :message, text: "Invalid input!"
        return false
      end
      @data = @player.win_loss(options)
    else
      @data = @player.win_loss
    end

    message = "Winrate: "
    message << construct_options_message(options) if args.any? 
    message << "#{@data["win"]} wins, #{@data["lose"]} losses"
    reply_with :message, text: message
  end

  alias_method :wl!, :winrate!

  private

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
        query[:included_account_id] << User.find_by(telegram_username: o[:value]).steam_id3
      else # Alias
        if o[:mode] == "as"
          query[:hero_id] = Alias.find_by(name: o[:value]).hero.hero_id
        elsif o[:mode] == "with"
          query[:with_hero_id] ||= []
          query[:with_hero_id] << Alias.find_by(name: o[:value]).hero.hero_id
        else # mode == "against"
          query[:against_hero_id] ||= []
          query[:against_hero_id] << Alias.find_by(name: o[:value]).hero.hero_id
        end
      end
    end
    return query
  end

  def construct_options_message(options)
    message_parts = []
    if options[:hero_id]
      message_parts << "as #{Hero.find_by(hero_id: options[:hero_id]).localized_name}"
    end
    if options[:with_hero_id]
      options[:with_hero_id].each do |id|
        message_parts << "with #{Hero.find_by(hero_id: id).localized_name}"
      end
    end
    if options[:against_hero_id]
      options[:against_hero_id].each do |id|
        message_parts << "against #{Hero.find_by(hero_id: id).localized_name}"
      end
    end
    message_parts << ""
    message_parts.join(" ")
  end

  def hero_or_player(string)
    Alias.find_by(name: string) || User.find_by(telegram_username: string)
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
