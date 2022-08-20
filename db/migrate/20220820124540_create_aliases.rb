class CreateAliases < ActiveRecord::Migration[7.0]
  def change
    create_table :aliases do |t|
      t.belongs_to :hero,      null:    false
      t.string     :name,      null:    false
      t.boolean    :default,   default: false
      t.boolean    :from_seed, default: false

      t.timestamps
      
      t.index :name,    unique: true
    end
  end
end
