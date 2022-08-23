module AliasHandling
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  def build_alias_resolution_message(options, intention)
    message = []
    if intention == "wl"
      message << "Winrate"
    elsif intention == "matches"
      message << "Matches"
    end
    message << build_options_message(options)
    message << "Which hero did you mean by the marked input?"
    message.join("\n")
  end

  def build_alias_resolution_keyboard(options)
    to_match = options.deep_locate -> (key, _, object) do
      key == :query && !object[:result] 
    end
    to_match = to_match.first[:query]
    possible_matches = Alias.where(name: to_match).includes(:hero).order("heroes.localized_name")
    keyboard = []
    possible_matches.each do |match|
      keyboard << [
        {
          text: match.hero.localized_name,
          callback_data: "alias:#{match.hero_id}"
        }
      ]
    end
    keyboard
  end

  def alias_callback_query(selection)
    options = session[:options]
    unclear = options.deep_locate -> (key, _, object) { key == :query && !object[:result] }
    unclear.first[:result] = selection.to_i
    session[:options] = clean_up_options session[:options]

    if unclear.count > 1
      edit_message :text, text:
        build_alias_resolution_message(session[:options], session[:intention])
      edit_message :reply_markup, reply_markup:
        {inline_keyboard: build_alias_resolution_keyboard(session[:options])}
    else
      # All set!
      if session[:intention] == "wl"
        data = session[:player].win_loss(session[:options])
        edit_message :text, text: build_win_loss_message(data, session[:options])
      elsif session[:intention] == "matches"
        session[:items] = session[:player].matches(session[:options])
        edit_message :text, text: build_matches_header(session[:items], session[:options])
        edit_message :reply_markup, reply_markup:
          {inline_keyboard: build_paginated_buttons(session[:items], 1)}
      end
    end
    answer_callback_query ""
  end
end
