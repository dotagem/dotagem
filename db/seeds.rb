# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Fetch constant data from OpenDota
GameMode.refresh
Hero.refresh
Item.refresh
LobbyType.refresh
Patch.refresh
Region.refresh

Nickname.destroy_by(from_seed: true)
# Parse custom aliases from file
# Aliases should be presented as an array of hashes, each
# hash containing a "name" and a "hero_id" field
# if "hero_id" is not present, give the full name of a hero as "hero"
# and we'll try and match it to the aliases currently on file
aliases = JSON.parse(File.read("#{Rails.root}/db/hero_aliases.json"))
aliases.each do |data|
  a = Nickname.new
  a.hero_id   = data["hero_id"] || Nickname.find_by(name: data["hero"]).hero.hero_id
  a.name      = data["name"].downcase
  a.from_seed = true
  a.save
end
