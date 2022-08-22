class User < ApplicationRecord
  DEFAULT_MATCH_OPTS = {project: ListMatch.attribute_names}

  def telegram_registered?
    self.telegram_id != nil
  end

  def steam_registered?
    self.steam_id64 != nil
  end

  # Returns a hash with a "win" and "loss" value
  def win_loss(opts = {})
    p = OpendotaPlayers.new(self.steam_id3)
    p.wl(opts)
  end

  # Returns an array of ListMatch objects
  def matches(opts = {})
    opts = DEFAULT_MATCH_OPTS.merge(opts)

    p = OpendotaPlayers.new(self.steam_id3)

    matches = []
    p.matches(opts).each do |match|
      matches << ListMatch.from_data(match)
    end
    matches
  end

  def heroes(opts = {})
    p = OpendotaPlayers.new(self.steam_id3)

    heroes = []
    p.heroes(opts).each do |hero|
      h = Hero.find_by(hero_id: hero['hero_id'])
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
    p = OpendotaPlayers.new(self.steam_id3)

    peers = []
    p.peers(opts).each do |peer|
      peers << Peer.from_data(peer)
    end
    peers
  end
end
