module Pagination
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::DateHelper

  PAGE_ITEMS = 5

  def build_paginated_buttons(items, page=1)
    i = (page - 1) * PAGE_ITEMS
    subset = items[i..i+PAGE_ITEMS-1]
    case items.first
    when ListMatch
      button_builder  = method(:match_button_text)
      button_callback = method(:match_button_callback)
    when Peer
      button_builder  = method(:peer_button_text)
      button_callback = method(:peer_button_callback)
    when Hero
      button_builder  = method(:hero_button_text)
      button_callback = method(:hero_button_callback)
    end

    keyboard = []
    subset.each do |item|
      keyboard << [
        {
          text: button_builder.call(item),
          callback_data: button_callback.call(item) 
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
  
  def pagination_callback_query(page)
    edit_message :reply_markup, reply_markup:
          {inline_keyboard: build_paginated_buttons(session[:items], page.to_i)}
    session[:page] = page
    answer_callback_query ""
  end

  # Button handlers

  def match_button_text(m)
    duration = m.duration / 60
    "#{m.wl} #{duration}min #{m.rd} #{m.kills}/#{m.deaths}/#{m.assists} " +
    "#{Hero.find_by(hero_id: m.hero_id).localized_name} " +
    "#{time_ago_in_words(Time.at(m.start_time))} ago"
  end

  def match_button_callback(match)
    "nothing:0"
  end

  def peer_button_text(p)
  end

  def peer_button_callback(peer)
  end

  def hero_button_text(p)
  end
  
  def hero_button_callback(peer)
  end
end
