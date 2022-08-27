class TelegramMatchesController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::TextHelper

  include MessageSession

  def match!(*args)
    if args.any?
      
    else
      respond_with :message, text: "You need to specify a match ID! It may be" +
      " easier to use /matches to find the match you are looking for."
    end
  end

  def match_callback_query(match_id)
    session[:match] = Match.from_api(match_id.to_i)
    session[:match_mode] = "overview"

    edit_message :text, text: build_match_overview_message(session[:match])
    edit_message :reply_markup, reply_markup: build_match_mode_buttons("overview")

    answer_callback_query ""
  end

  def match_mode_callback_query(mode)

  end

  private

  def build_match_mode_buttons(current_mode)
    
  end

  def build_match_overview_message(match)

  end
end
