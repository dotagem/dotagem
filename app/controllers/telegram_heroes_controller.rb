class TelegramHeroesController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::TextHelper

  def alias!(*args)
    input = args.join(" ").downcase
    aliases = Alias.where(name: input)

    case aliases.count
    when 0
      respond_with :message, text: "Which hero do you want aliases for? Try \"/alias hero name\"!"
    when 1
      respond_with :message, text: build_alias_list_message(aliases.first.hero_id)
    else
      intention = "alias_list"
      result = respond_with :message,
        text: build_single_alias_message(input, intention),
        reply_markup: {inline_keyboard: build_single_alias_keyboard(input, intention)}
    end
  end

  alias_method :aliases!, :alias!

  def alias_list_callback_query(hero_id)
    edit_message :text, text: build_alias_list_message(hero_id.to_i)
    answer_callback_query ""
  end

  private

  def build_alias_list_message(hero_id)
    message = []
    aliases = Alias.where(hero_id: hero_id).order(:name)
    message << "#{pluralize(aliases.count, "alias")} for " +
    "#{Hero.find_by(hero_id: hero_id).localized_name}:"
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
    end
    message << "Which hero did you mean by \"#{input}\"?"

    return message.join("\n")
  end

  def build_single_alias_keyboard(input, intention)
    aliases = Alias.where(name: input).includes(:hero).order("heroes.localized_name")
    keyboard = []
    aliases.each do |a|
      keyboard << [
        {
          text: Hero.find_by(hero_id: a.hero_id).localized_name,
          callback_data: "#{intention}:#{a.hero_id}"
        }
      ]
    end
    return keyboard
  end
end
