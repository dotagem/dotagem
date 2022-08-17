class User < ApplicationRecord
  def telegram_registered?
    self.telegram_id != nil
  end

  def steam_registered?
    self.steam_id64 != nil
  end

  def win_loss(hero=nil)
    p = OpendotaPlayers.new(self.steam_id3)
    if hero
      p.wl(hero_id: hero)
    else
      p.wl
    end
  end
end
