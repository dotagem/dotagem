class TelegramMatchesController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include ActionView::Helpers::TextHelper

  include MessageSession

  def match!(*args)
    if args.any?
      
    else
      respond_with :message, text: "You need to specify a match ID! It may be" +
      " easier to use /matches to find the match you are looking for."
    end
  end

  def lastmatch!(*args)

  end

  private

  def build_list_match_message(listmatch)

  end

  def build_match_overview_message(match)

  end
end
