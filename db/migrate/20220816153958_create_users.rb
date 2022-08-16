class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.boolean :admin, default: false
      t.integer :telegram_id,       unique: true, null: false
      t.string  :telegram_username
      t.string  :telegram_avatar
      t.integer :steam_id64,        unique: true
      t.string  :steam_id3,         unique: true
      t.string  :steam_nickname
      t.string  :steam_url
      t.string  :steam_avatar

      t.timestamps

      t.index :telegram_id, unique: true
      t.index :steam_id64,  unique: true
      t.index :steam_id3,   unique: true
    end
  end
end
