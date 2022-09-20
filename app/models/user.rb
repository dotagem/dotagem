class User < ApplicationRecord
  include OpendotaHelper

  validates :telegram_id,       presence: true,
                                uniqueness: true
  validates :telegram_username, presence: true,
                                uniqueness: true
  validates :steam_id,          format: {
                                  with: /\A[0-9]+\z/,
                                  message: "must be numerical"
                                },
                                uniqueness: true,
                                allow_nil: true
  validates :steam_id64,        uniqueness: true,
                                allow_nil: true

  DEFAULT_MATCH_OPTS = {project: ListMatch.attribute_names, limit: 500}

  def telegram_registered?
    self.telegram_id != nil
  end

  def steam_registered?
    self.steam_id64 != nil
  end

  # Returns a hash with a "win" and "loss" value
  def win_loss(opts = {})
    p = OpendotaPlayers.new(self.steam_id)
    p.wl(opts)
  end

  # Returns an array of ListMatch objects
  def matches(opts = {})
    opts = DEFAULT_MATCH_OPTS.merge(opts)

    p = OpendotaPlayers.new(self.steam_id)

    matches = []
    p.matches(opts).each do |match|
      matches << ListMatch.from_data(match)
    end
    matches
  end

  def rank
    p = OpendotaPlayers.new(self.steam_id)
    data = p.info
    format_rank(data["rank_tier"], data["leaderboard_rank"])
  end

  def heroes(opts = {})
    p = OpendotaPlayers.new(self.steam_id)

    heroes = []
    p.heroes(opts).each do |hero|
      h = Hero.find_by(hero_id: hero['hero_id'].to_i)
      h.last_played =   hero['last_played']
      h.games =         hero['games']
      h.win =           hero['win']
      h.with_games =    hero['with_games']
      h.with_win =      hero['with_win']
      h.against_games = hero['against_games']
      h.against_win =   hero['against_win']
      heroes << h
    end
    heroes
  end

  # Returns an array of Peer objects
  def peers(opts = {})
    p = OpendotaPlayers.new(self.steam_id)

    peers = []
    p.peers(opts).each do |peer|
      peers << Peer.from_data(peer)
    end
    peers
  end
end
