class TelegramMatchesController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include ActionView::Helpers::TextHelper

  include MatchMessages
  include MessageSession

  def match!(*args)
    if args.any? && args.count == 1 && args.first.to_i > 0
      match_id = args.first.to_i
      @match = Match.from_api(match_id)

      result = respond_with :message, text: build_match_overview_message(@match),
        reply_markup: {inline_keyboard: build_match_overview_keyboard(@match)}
    else
      respond_with :message, text: "You need to specify a match ID! It may be" +
      " easier to use /matches to find the match you are looking for."
    end
  end

  def match_callback_query(match_id)
    @match = Match.from_api(match_id.to_i)

    edit_message :text, text: build_match_overview_message(@match)
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_match_overview_keyboard(@match)
    }

    answer_callback_query ""
  end
end
