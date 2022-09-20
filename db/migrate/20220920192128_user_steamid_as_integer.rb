class UserSteamidAsInteger < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :steam_id, "bigint USING steam_id::bigint"
  end
end
