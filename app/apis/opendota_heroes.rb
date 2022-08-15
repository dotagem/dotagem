class OpendotaHeroes
  include HTTParty
  base_uri 'api.opendota.com/api/heroes'

  def initialize(hero_id)
    @hero_id = hero_id.to_s
  end

  def all
    self.class.get("/")
  end

  def info
    self.class.get("/").select { |hero| hero["id"] == @hero_id.to_i }
  end

  def matchups
    self.class.get("/#{@hero_id}/matchups")    
  end

  def durations
    self.class.get("/#{@hero_id}/durations")
  end

  def item_popularity
    self.class.get("/#{@hero_id}/item_popularity")
  end
end
