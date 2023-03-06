class ChangeTelegramIdToBignum < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :telegram_id, :bigint
  end
end
