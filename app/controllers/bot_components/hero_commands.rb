module BotComponents::HeroCommands
  extend ActiveSupport::Concern

  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  include ActionView::Helpers::TextHelper

  include Pagination
  include ButtonProcStrings
  include MessageSession
  include ConstantsHelper

  def alias!(*args)
    if args.any?
      input = args.join(" ").downcase
      aliases = Nickname.where(name: input)

      case aliases.count
      when 0
        respond_with :message, text: "I don't understand which hero you mean, sorry!"
      when 1
        respond_with :message, text: build_alias_list_message(aliases.first.hero_id)
      else
        intention = "alias_list"
        result = respond_with :message,
          text: build_single_alias_message(input, intention),
          reply_markup: {inline_keyboard: build_single_alias_keyboard(input, intention)}
      end
    else
      respond_with :message,
        text: "Which hero do you want aliases for? Try \"/alias hero name\"!"
    end
  end

  alias_method :aliases!, :alias!

  def alias_list_callback_query(hero_id)
    edit_message :text, text: build_alias_list_message(hero_id.to_i)
    answer_callback_query ""
  end

  def matchups!(*args)
    if args.any?
      input = args.join(" ").downcase
      aliases = Nickname.where(name: input)

      case aliases.count
      when 0
        respond_with :message, text: "I don't understand which hero you mean, sorry!"
      when 1
        matchups = aliases.first.hero.matchups.sort_by { |m| m.wilson_against }.reverse!
        result = respond_with :message,
          text: build_matchup_message(aliases.first.hero_id),
          reply_markup: { inline_keyboard:
            build_paginated_buttons(matchups, matchup_button_proc_string)
          }
        message_session(result['result']['message_id'])
        message_session[:items] = matchups
        message_session[:page] = 1
        message_session[:button] = matchup_button_proc_string
      else
        intention = "matchups"
        result = respond_with :message,
          text: build_single_alias_message(input, intention),
          reply_markup: {inline_keyboard: build_single_alias_keyboard(input, intention)}
      end
    else
      respond_with :message,
        text: "Which hero do you want matchups for? Try \"/matchup hero name\"!"
    end
  end

  def matchups_callback_query(hero_id)
    matchups = Hero.find_by(hero_id: hero_id).matchups.sort_by { |m| m.wilson_against }.reverse!
    edit_message :text, text: build_matchup_message(hero_id.to_i)
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_paginated_buttons(matchups, matchup_button_proc_string)
    }
    session[:items] = matchups
    session[:page] = 1
    session[:button] = matchup_button_proc_string

    answer_callback_query ""
  end

  private

  def build_alias_list_message(hero_id)
    message = []
    aliases = Nickname.where(hero_id: hero_id).order(:name)
    message << "#{pluralize(aliases.count, "alias")} for " +
    "#{hero_name(hero_id)}:"
    aliases.each do |a|
      str = "- #{a.name}"
      str << " [A]" if a.default?
      str << " [S]" if a.from_seed?
      message << str
    end
    message << "\nKey:"
    message << "[A] = automatically generated aliases"
    message << "[S] = aliases from the default database seed"
    return message.join("\n")
  end

  def build_single_alias_message(input, intention)
    message = []
    case intention
    when "alias_list"
      message << "Alias list"
    when "matchups"
      message << "Matchups"
    end
    message << "Which hero did you mean by \"#{input}\"?"

    return message.join("\n")
  end

  def build_single_alias_keyboard(input, intention)
    aliases = Nickname.where(name: input).includes(:hero).order("heroes.localized_name")
    keyboard = []
    aliases.each do |a|
      keyboard << [
        {
          text: hero_name(a.hero_id),
          callback_data: "#{intention}:#{a.hero_id}"
        }
      ]
    end
    return keyboard
  end

  def build_matchup_message(hero_id)
    hero = Hero.find_by(hero_id: hero_id)

    message = ["Matchups for #{hero.localized_name}"]
    message << "Sorted by Wilson score, best to worst"
    message.join("\n")
  end
end
