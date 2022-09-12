module MatchMessages

  private

  def build_match_overview_message(m)
    message = []
    message << "Match #{m.match_id}"
    message << ""
    message << "Final score: #{m.radiant_score} - #{m.dire_score}"
    message << "Result: #{m.radiant_win ? "Radiant" : "Dire"} victory " +
               "in #{m.duration / 60} minutes"
    message << "Mode: #{GameMode.find_by(mode_id: m.game_mode).localized_name}, " +
               "#{LobbyType.find_by(lobby_id: m.lobby_type).localized_name}, " +
               "#{Region.find_by(region_id: m.region).localized_name}"
    known_players = m.players.select { |p| p.known? }
    if known_players.any?
      message << ""
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
