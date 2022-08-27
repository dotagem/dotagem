class ListMatch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :match_id
  attribute :player_slot
  attribute :radiant_win
  attribute :duration
  attribute :game_mode
  attribute :lobby_type
  attribute :region
  attribute :hero_id
  attribute :start_time
  attribute :kills
  attribute :deaths
  attribute :assists
  attribute :average_rank
  attribute :leaver_status
  attribute :party_size
  attribute :gold_per_min
  attribute :xp_per_min
  attribute :hero_damage
  attribute :tower_damage
  attribute :hero_healing
  attribute :last_hits
  attribute :denies
  attribute :lane
  attribute :lane_role
  attribute :is_roaming
  attribute :cluster
  attribute :version

  def self.from_data(data)
    match = self.new
    match.attributes.each_pair do |k, _|
      match.send("#{k}=", data[k])
    end
    match
  end

  def won?
    if self.player_slot < 128
      self.radiant_win ? true : false
    else
      self.radiant_win ? false : true
    end
  end

  def is_radiant?
    self.player_slot < 128 ? true : false
  end

  def rd
    self.is_radiant? ? "R" : "D"
  end

  def wl
    self.won? ? "W" : "L"
  end

  def parsed?
    !self.version.nil?
  end

  def persisted?
    false
  end
end
