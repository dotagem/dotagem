class Hero < ApplicationRecord
  include Wilson

  attribute :last_played,    default: nil
  attribute :games,          default: nil
  attribute :win,            default: nil
  attribute :with_games,     default: nil
  attribute :with_win,       default: nil
  attribute :against_games,  default: nil
  attribute :against_win,    default: nil

  has_many :aliases, primary_key: :hero_id

  serialize :roles

  def self.refresh
    # We're atomic baby
    ActiveRecord::Base.transaction do
      self.destroy_all
      # We're regenerating default aliases too
      Alias.destroy_by(default: true)

      # Iterate over heroes OpenDota knows about and add them to our database
      OpendotaHeroes.all.each do |hero|
        h = self.new
        hero.each_pair do |k, v|
          k = "hero_id" if k == "id"
          # This was reported wrong in the dataset a whole year ago now:
          v = "Outworld Destroyer" if v == "Outworld Devourer"
          h[k] = v
        end
        h.save
        h.generate_default_aliases
      end
    end
  end

  def generate_default_aliases
    name  = self.localized_name.downcase
    words = name.split(/[\s-]/)

    # The hero's full name
    self.aliases.create(name: name, default: true)

    if name.include?("-")
      self.aliases.create(name: name.tr("-", ""), default: true)
    end

    # If the hero's name consists of more than 2 words, an abbreviation,
    # the first and the last word, with and without non-alpha characters
    if words.count > 1
      abbreviation = ""
      words.each do |word|
        abbreviation << word.chr
      end
      self.aliases.create(name: abbreviation, default: true)
      self.aliases.create(name: words.first,  default: true)
      self.aliases.create(name: words.last,   default: true)
    end
  end

  def wilson
    wilson_score(self.games, self.win)
  end

  def wilson_with
    wilson_score(self.with_games, self.with_win)
  end

  def wilson_against
    wilson_score(self.against_games, self.against_win)
  end

  def matchups
    api = OpendotaHeroes.new(self.hero_id)
    heroes = []
    api.matchups.each do |hero|
      h = Hero.find_by(hero_id: hero['hero_id'])
      h.against_games  = hero['games_played']
      h.against_win    = hero['wins']

      heroes << h
    end

    return heroes
  end
end
