class ChangeDataTypeOnSteamId < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :steam_id64, :bigint
  end
end
