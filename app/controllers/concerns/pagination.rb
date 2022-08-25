module Pagination
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  PAGE_ITEMS = 5

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
  
  def pagination_callback_query(page)
    edit_message :reply_markup, reply_markup:
          {inline_keyboard: build_paginated_buttons(session[:items], session[:button], page.to_i)}
    session[:page] = page
    answer_callback_query ""
  end
end
