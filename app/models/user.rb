class User < ApplicationRecord
  DEFAULT_MATCH_OPTS = {limit: 5, offset: 0, project: ListMatch.attribute_names}

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
