class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.integer :item_id,  null: false, unique: true
      t.string :name,      null: false, unique: true
      t.string :img
      t.string :dname,     null: false
      t.string :qual
      t.integer :cost
      t.string :components
      t.string :lore
      t.boolean :created

      t.timestamps

      t.index :item_id, unique: true
      t.index :name,    unique: true
    end
  end
end
