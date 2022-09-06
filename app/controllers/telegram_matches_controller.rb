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
        reply_markup: {inline_keyboard: build_match_overview_keyboard(@match)}
      message_session(result['result']['message_id'])
      message_session[:match] = @match
    else
      respond_with :message, text: "You need to specify a match ID! It may be" +
      " easier to use /matches to find the match you are looking for."
    end
  end

  def match_callback_query(match_id)
    session[:match] = Match.from_api(match_id.to_i)

    edit_message :text, text: build_match_overview_message(session[:match])
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: build_match_overview_keyboard(session[:match])
    }

    answer_callback_query ""
  end

  private

  def build_match_overview_message(m)
    message = []
    message << "Match #{m.match_id}"
    message << ""
    message << "Result: #{m.radiant_win ? "Radiant" : "Dire"} victory " +
               "in #{m.duration / 60} minutes"
    message << "Mode: #{GameMode.find_by(mode_id: m.game_mode).localized_name}, " +
               "#{LobbyType.find_by(lobby_id: m.lobby_type).localized_name}, " +
               "#{Region.find_by(region_id: m.region).localized_name}"
    known_players = m.players.select { |p| p.known? }
    if known_players.any?
      formatted_players = []
      known_players.each do |p|
        formatted_players << User.find_by(steam_id: p.account_id).telegram_username + 
                             " as #{Hero.find_by(hero_id: p.hero_id).localized_name}"
      end
      message << "Known players: #{formatted_players.join", "}"
    end
    return message.join("\n")
  end

  def build_match_overview_keyboard(match)
    [[
      {
        text: "Match details on OpenDota",
        url: "https://opendota.com/matches/#{match.match_id}"
      }
    ]]
  end
end
