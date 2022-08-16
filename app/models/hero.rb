class Hero < ApplicationRecord
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
          v = "Outworld Destroyer" if v == "Outworld Devourer"
          h[k] = v
        end
        h.save
      end
    end
  end
end
