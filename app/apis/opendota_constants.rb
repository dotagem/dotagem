class OpendotaConstants
  include HTTParty
  base_uri 'https://api.opendota.com/api/constants'

  def initialize(resource)
    @resource = resource
  end

  def all
    self.class.get("/#{@resource}")
  end
end
