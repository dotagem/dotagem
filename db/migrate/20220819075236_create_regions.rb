class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions do |t|
      t.integer :region_id,     null: false, unique: true
      t.string :name,           null: false
      t.string :localized_name, null: false

      t.timestamps

      t.index :region_id, unique: true
    end
  end
end
