class Match
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :match_id
  attribute :barracks_status_dire
  attribute :barracks_status_radiant
  attribute :start_time
  attribute :radiant_win
  attribute :duration
  attribute :radiant_score
  attribute :dire_score
  attribute :players
  attribute :picks_bans
  attribute :lobby_type
  attribute :game_mode

  def self.from_api(match_id)
    data = OpendotaMatches.new(match_id).show
    match = Match.new
    match.attributes.each_pair do |k, _|
      match.send("#{k}=", data[k]) unless k == "players"
    end
    match.players = []
    data["players"].each do |playerdata|
      match.players << MatchPlayer.from_data(playerdata)
    end
    match
  end

  def persisted?
    false
  end
end
