class Hero < ApplicationRecord
  attribute :last_played,   default: nil
  attribute :games,         default: nil
  attribute :win,           default: nil
  attribute :with_games,    default: nil
  attribute :with_win,      default: nil
  attribute :against_games, default: nil
  attribute :against_win,   default: nil

  serialize :roles

  def self.refresh
    # We're atomic baby
    ActiveRecord::Base.transaction do
      self.destroy_all

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
      end
    end
  end
end
