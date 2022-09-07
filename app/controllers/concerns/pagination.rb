module Pagination
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  
  PAGE_ITEMS = 5

  def pagination_callback_query(page)
    @player ||= User.find(session[:player])
    keyboard = []
    if session[:hero_mode] && session[:hero_sort]
      keyboard << build_hero_mode_buttons(session[:hero_mode])
      keyboard << build_hero_sort_buttons(session[:hero_sort])
    end
    keyboard += build_paginated_buttons(session[:items], session[:button], page.to_i)
    edit_message :reply_markup, reply_markup:
          {inline_keyboard: keyboard}
    session[:page] = page
    answer_callback_query ""
  end
  
  def change_hero_mode_callback_query(target)
    session[:page] = 1
    session[:hero_mode] = target
    session[:items] = sort_heroes_by_mode(
      session[:items], session[:hero_mode], session[:hero_sort]
    )

    case target
    when "as"
      session[:button] = hero_as_button_proc_string
    when "with"
      session[:button] = hero_with_button_proc_string
    when "against"
      session[:button] = hero_against_button_proc_string
    end
  
    keyboard = []
    keyboard << build_hero_mode_buttons(session[:hero_mode])
    keyboard << build_hero_sort_buttons(session[:hero_sort])
    keyboard = keyboard + build_paginated_buttons(session[:items], session[:button])

    edit_message :reply_markup, reply_markup: {inline_keyboard: keyboard}

    answer_callback_query ""
  end
  
  def change_hero_sort_callback_query(target)
    session[:page] = 1
    session[:hero_sort] = target
    session[:items] = sort_heroes_by_mode(
      session[:items], session[:hero_mode], session[:hero_sort]
    )

    keyboard = []
    keyboard << build_hero_mode_buttons(session[:hero_mode])
    keyboard << build_hero_sort_buttons(session[:hero_sort])
    keyboard += build_paginated_buttons(session[:items], session[:button])

    edit_message :reply_markup, reply_markup: {inline_keyboard: keyboard}

    answer_callback_query ""
  end

  def change_peer_sort_callback_query(target)
    session[:page] = 1
    session[:peer_sort] = target
    session[:items] = sort_peers_by_mode(
      session[:items], session[:peer_sort]
    )

    keyboard = []
    keyboard << build_peer_sort_buttons(session[:peer_sort])
    keyboard += build_paginated_buttons(session[:items], session[:button])

    edit_message :reply_markup, reply_markup: {
      inline_keyboard: keyboard
    }

    answer_callback_query ""
  end

  private
  
  def build_paginated_buttons(items, button_builder, page=1)
    i = (page - 1) * PAGE_ITEMS
    subset = items[i..i+PAGE_ITEMS-1]
    builder = eval button_builder

    keyboard = []
    subset.each do |item|
      t, c = builder.call(item)
      keyboard << [
        {
          text: t,
          callback_data: c 
        }
      ]
    end

    pages = items.count / PAGE_ITEMS
    if (items.count % PAGE_ITEMS) > 0
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

  def build_hero_mode_buttons(mode)
    row = []
    row << {
      text: "Mode:",
      callback_data: "nothing:0"
    }
    row << {
      text: "As",
      callback_data: "change_hero_mode:as"
    }
    row << {
      text: "With",
      callback_data: "change_hero_mode:with"
    }
    row << {
      text: "Against",
      callback_data: "change_hero_mode:against"
    }
    # Ensure the current mode is marked and does not callback
    case mode
    when "as"
      row.second[:text] = "[As]"
      row.second[:callback_data] = "nothing:0"
    when "with"
      row.third[:text] = "[With]"
      row.third[:callback_data] = "nothing:0"
    when "against"
      row.last[:text] = "[Against]"
      row.last[:callback_data] = "nothing:0"
    end

    return row
  end

  def build_hero_sort_buttons(sort)
    row = []
    row << { 
      text: "Sort:",
      callback_data: "nothing:0"
    }
    row << {
      text: "Games",
      callback_data: "change_hero_sort:games"
    }
    row << {
      text: "Win %",
      callback_data: "change_hero_sort:win"
    }
    row << {
      text: "A-Z",
      callback_data: "change_hero_sort:alphabetical"
    }
    case sort
    when "games"
      row.second[:text]          = "[Games]"
      row.second[:callback_data] = "nothing:0"
    when "win"
      row.third[:text]          = "[Win %]"
      row.third[:callback_data] = "nothing:0"
    when "alphabetical"
      row.last[:text]          = "[A-Z]"
      row.last[:callback_data] = "nothing:0"
    end

    return row
  end

  def build_peer_sort_buttons(sort)
    row = []
    row << { 
      text: "Sort:",
      callback_data: "nothing:0"
    }
    row << {
      text: "Games",
      callback_data: "change_peer_sort:games"
    }
    row << {
      text: "Win %",
      callback_data: "change_peer_sort:win"
    }
    row << {
      text: "A-Z",
      callback_data: "change_peer_sort:alphabetical"
    }
    case sort
    when "games"
      row.second[:text]          = "[Games]"
      row.second[:callback_data] = "nothing:0"
    when "win"
      row.third[:text]          = "[Win %]"
      row.third[:callback_data] = "nothing:0"
    when "alphabetical"
      row.last[:text]          = "[A-Z]"
      row.last[:callback_data] = "nothing:0"
    end

    return row
  end

  def sort_peers_by_mode(items, sort)
    case sort
    when "games"
      sorted = items.sort_by {|i| i.with_games}.reverse!
    when "win"
      sorted = items.sort_by do |i|
        res = i.with_win / i.with_games.to_f
        res.nan? ? -1 : res
      end
    when "alphabetical"
      sorted = items.sort_by do |i|
        User.find_by(steam_id: i.account_id).telegram_username
      end
    end
  end

  # Sorting depends on both mode and sort, so here's a funny little matrix
  def sort_heroes_by_mode(items, mode, sort)
    case sort
    when "games"
      case mode
      when "as"
        sorted = items.sort_by {|i| i.games}.reverse!
      when "with"
        sorted = items.sort_by {|i| i.with_games}.reverse!
      when "against"
        sorted = items.sort_by {|i| i.against_games}.reverse!
      end
    when "win"
      case mode
      when "as"
        sorted = items.sort_by do |i| 
          res = i.win / i.games.to_f
          res.nan? ? -1 : res
        end.reverse!
      when "with"
        sorted = items.sort_by do |i|
          res = i.with_win / i.with_games.to_f
          res.nan? ? -1 : res
        end.reverse!
      when "against"
        sorted = items.sort_by do |i|
          res = i.against_win / i.against_games.to_f
          res.nan? ? -1 : res
        end.reverse!
      end
    when "alphabetical"
      sorted = items.sort_by {|i| i.localized_name}
    end
    return sorted
  end
end
