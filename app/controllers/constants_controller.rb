class ConstantsController < ApplicationController
  before_action :admin_user

  def refresh
    GameMode.refresh
    Hero.refresh
    Item.refresh
    LobbyType.refresh
    Patch.refresh
    Region.refresh

    Alias.destroy_by(from_seed: true)
    # Parse custom aliases from file
    # Aliases should be presented as an array of hashes, each
    # hash containing a "name" and a "hero_id" field
    # if "hero_id" is not present, give the full name of a hero as "hero"
    # and we'll try and match it to the aliases currently on file
    aliases = JSON.parse(File.read("#{Rails.root}/db/hero_aliases.json"))

    aliases.each do |data|
      a = Alias.new
      a.hero_id   = data["hero_id"] || Alias.find_by(name: data["hero"]).hero.hero_id
      a.name      = data["name"].downcase
      a.from_seed = true
      a.save
    end

    flash[:notice] = "Constants successfully updated!"
    redirect_to admin_url, status: 303
  end
end
