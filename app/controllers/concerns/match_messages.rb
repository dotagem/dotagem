module MatchMessages
  include ActionView::Helpers::DateHelper
  include OpendotaHelper
  include MatchDataHelper

  private

  def build_short_match_message(m)
    message = []
    message << "Recent match for #{@player.telegram_username}"
    message << ""
    message << "Hero: #{hero_name(m.hero_id)}"
    message << "Result: #{m.won? ? "Win" : "Loss"} in #{m.duration / 60} mins"
    message << "Played #{time_ago_in_words(Time.at(m.start_time))} ago\n"
    message << "KDA: #{m.kills}/#{m.deaths}/#{m.assists}, LH/D: #{m.last_hits}/#{m.denies}"
    message << "Mode: #{game_mode_name(m.game_mode)}, " +
               "#{lobby_type_name(m.lobby_type)}, " +
               "#{region_name(m.region)}"
    message << "Avg. rank: #{format_rank(m.average_rank)}"
    message << "Party of #{m.party_size || 1}"

    message.join("\n")
  end

  def build_match_overview_message(m)
    message = []
    message << "Match #{m.match_id}"
    message << ""
    message << "Final score: #{m.radiant_score} - #{m.dire_score}"
    message << "Result: #{m.radiant_win ? "Radiant" : "Dire"} victory " +
               "in #{m.duration / 60} minutes"
    message << "Mode: #{game_mode_name(m.game_mode)}, " +
               "#{lobby_type_name(m.lobby_type)}, " +
               "#{region_name(m.region)}"
    known_players = m.players.select { |p| p.known? }
    if known_players.any?
      message << ""
      formatted_players = []
      known_players.each do |p|
        formatted_players << User.find_by(steam_id: p.account_id).telegram_username + 
                             " as #{hero_name(p.hero_id)}"
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
