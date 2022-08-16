class CreateHeroes < ActiveRecord::Migration[7.0]
  def change
    create_table :heroes do |t|
      t.integer :hero_id,        null: false, unique: true
      t.string  :name,           null: false
      t.string  :localized_name, null: false
      t.string  :primary_attr
      t.string  :attack_type
      t.string  :roles
      t.integer :legs

      t.timestamps

      t.index :hero_id, unique: true
      t.index :localized_name
    end
  end
end
