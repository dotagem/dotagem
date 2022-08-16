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

class MatchPlayer
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :player_slot
  attribute :account_id
  attribute :kills
  attribute :deaths
  attribute :assists
  attribute :item_0
  attribute :item_1
  attribute :item_2
  attribute :item_3
  attribute :item_4
  attribute :item_5
  attribute :backpack_0
  attribute :backpack_1
  attribute :backpack_2
  attribute :hero_damage
  attribute :hero_healing
  attribute :creeps_stacked
  attribute :denies
  attribute :gold
  attribute :gold_per_min
  attribute :hero_id
  attribute :level
  attribute :leaver_status
  attribute :permanent_buffs
  attribute :tower_damage
  attribute :xp_per_min

  def self.from_data(data)
    player = MatchPlayer.new
    player.attributes.each_pair do |k, _|
      player.send("#{k}=", data[k])
    end
    player
  end

  def gpm
    gold_per_min
  end

  def xpm
    xp_per_min
  end

  def is_radiant?
    player_slot < 128
  end

  def persisted?
    false
  end
end
