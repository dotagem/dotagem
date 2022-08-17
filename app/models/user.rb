class User < ApplicationRecord
  def telegram_registered?
    self.telegram_id != nil
  end

  def steam_registered?
    self.steam_id64 != nil
  end
end
