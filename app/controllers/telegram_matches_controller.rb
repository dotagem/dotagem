class TelegramMatchesController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::TextHelper

  include MessageSession

  def match!(*args)
    if args.any? && args.count == 1 && args.first.to_i > 0
      match_id = args.first.to_i
      @match = Match.from_api(match_id)

      result = respond_with :message, text: build_match_overview_message(@match),
        reply_markup: {inline_keyboard: build_match_mode_buttons("overview")}
      message_session(result['result']['message_id'])
      message_session[:match]      = @match
      message_session[:match_mode] = "overview"
    else
      respond_with :message, text: "You need to specify a match ID! It may be" +
      " easier to use /matches to find the match you are looking for."
    end
  end

  def match_callback_query(match_id)
    session[:match]      = Match.from_api(match_id.to_i)
    session[:match_mode] = "overview"

    edit_message :text, text: build_match_overview_message(session[:match])
    edit_message :reply_markup, reply_markup: {inline_keyboard: build_match_mode_buttons("overview")}

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
