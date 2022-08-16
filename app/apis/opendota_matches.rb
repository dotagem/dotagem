class OpendotaMatches
  include HTTParty
  base_uri 'https://api.opendota.com/api/matches'

  def initialize(match_id)
    @match_id = match_id
  end

  def show
    self.class.get("/#{@match_id}")
  end
end
