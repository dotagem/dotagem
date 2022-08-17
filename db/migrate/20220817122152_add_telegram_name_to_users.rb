class AddTelegramNameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :telegram_name, :string
  end
end
