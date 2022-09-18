class DowncaseTelegramUsernames < ActiveRecord::Migration[7.0]
  def change
    User.update_all('telegram_username = lower(telegram_username)')
  end
end
