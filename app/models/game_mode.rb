class GameMode < ApplicationRecord
  validates :mode_id,        presence: true
  validates :name,           presence: true
  validates :localized_name, presence: true
  
  def self.refresh
    ActiveRecord::Base.transaction do
      self.destroy_all

      OpendotaConstants.new("game_mode").all.each do |mode|
        m = self.new
        mode.second.each_pair do |k, v|
          k = "mode_id" if k == "id"
          m.send("#{k}=", v)
        end
        # Make a nice titleized name out of the game modes
        m.localized_name = mode.second["name"].titleize.
                           split(' ')[2..-1].join(' ')
        m.save
      end
    end
  end
end
