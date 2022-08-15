class OpendotaPlayers
  include HTTParty
  base_uri 'api.opendota.com/api/players'

  def initialize(player_id)
    @player_id = player_id
  end

  def info
    self.class.get("/#{@player_id}")
  end

  def wl
    self.class.get("/#{@player_id}/wl")
  end

  def matches(opts = {})
    self.class.get("/#{@player_id}/matches", query: opts)
  end

  def heroes(opts = {})
    self.class.get("/#{@player_id}/heroes", query: opts)
  end

  def peers(opts = {})
    self.class.get("/#{@player_id}/peers", query: opts)
  end

  def wordcloud
    self.class.get("/#{@player_id}/wordcloud")
  end
end
