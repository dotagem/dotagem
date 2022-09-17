class Hero < ApplicationRecord
  include Wilson

  CDN_BASE_URL = "https://cdn.cloudflare.steamstatic.com"

  validates :hero_id,        presence: true,
                             uniqueness: true
  validates :name,           presence: true
  validates :localized_name, presence: true

  attribute :last_played,    default: nil
  attribute :games,          default: nil
  attribute :win,            default: nil
  attribute :with_games,     default: nil
  attribute :with_win,       default: nil
  attribute :against_games,  default: nil
  attribute :against_win,    default: nil

  has_many :nicknames, primary_key: :hero_id

  serialize :roles

  def self.refresh
    # We're atomic baby
    ActiveRecord::Base.transaction do
      self.destroy_all
      # We're regenerating default aliases too
      Nickname.destroy_by(default: true)

      # Iterate over heroes OpenDota knows about and add them to our database
      OpendotaConstants.new("heroes").all.each_pair do |_, hero|
        h = self.new
        
        h.hero_id        = hero['id']
        h.name           = hero['name']
        h.localized_name = hero['localized_name']
        h.primary_attr   = hero['primary_attr']
        h.attack_type    = hero['attack_type']
        h.roles          = hero['roles']
        h.legs           = hero['legs']
        h.image          = hero['img']
        h.icon           = hero['icon']

        # This was reported wrong in the dataset a whole year ago now:
        h.localized_name = "Outworld Destroyer" if h.localized_name == "Outworld Devourer"
        
        h.save
        h.generate_default_nicknames
      end
    end
  end

  def generate_default_nicknames
    name  = self.localized_name.downcase
    words = name.split(/[\s-]/)

    # The hero's full name
    self.nicknames.create(name: name, default: true)

    if name.include?("-")
      self.nicknames.create(name: name.tr("-", ""), default: true)
    end

    # If the hero's name consists of more than 2 words, an abbreviation,
    # the first and the last word, with and without non-alpha characters
    if words.count > 1
      abbreviation = ""
      words.each do |word|
        abbreviation << word.chr
      end
      self.nicknames.create(name: abbreviation, default: true)
      self.nicknames.create(name: words.first,  default: true)
      self.nicknames.create(name: words.last,   default: true)
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

  def image_url
    CDN_BASE_URL + self.image
  end

  def icon_url
    CDN_BASE_URL + self.icon
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
