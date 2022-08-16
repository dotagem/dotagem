class LobbyType < ApplicationRecord
  def self.refresh
    ActiveRecord::Base.transaction do
      self.destroy_all

      OpendotaConstants.new("lobby_type").all.each do |type|
        t = self.new
        type.second.each_pair do |k, v|
          k = "lobby_id" if k == "id"
          t.send("#{k}=", v)
        end
        # Make a nice titleized name out of the game modes
        t.localized_name = type.second["name"].titleize.
                           split(' ')[2..-1].join(' ')
        t.save
      end
    end
  end
end
