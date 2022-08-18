class ListMatch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :match_id
  attribute :player_slot
  attribute :radiant_win
  attribute :duration
  attribute :game_mode
  attribute :lobby_type
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
      player.send("#{k}=", data[k])
    end
    match
  end

  def parsed?
    !self.version.nil?
  end

  def persisted?
    false
  end
end
