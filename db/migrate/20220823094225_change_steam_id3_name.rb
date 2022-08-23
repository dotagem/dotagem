class ChangeSteamId3Name < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :steam_id3, :steam_id
  end
end
