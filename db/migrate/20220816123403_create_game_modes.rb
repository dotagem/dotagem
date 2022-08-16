class CreateGameModes < ActiveRecord::Migration[7.0]
  def change
    create_table :game_modes do |t|
      t.integer :mode_id,        null: false, unique: true
      t.string  :name,           null: false
      t.string  :localized_name
      t.boolean :balanced,       default: false

      t.timestamps

      t.index :mode_id, unique: true
    end
  end
end
