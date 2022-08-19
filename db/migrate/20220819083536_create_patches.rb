class CreatePatches < ActiveRecord::Migration[7.0]
  def change
    create_table :patches do |t|
      t.integer :patch_id, null: false, unique: true
      t.string  :name,     null: false

      t.timestamps
      t.index :patch_id, unique: true
    end
  end
end
