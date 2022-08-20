class RemoveUniqueConstraintFromAliases < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        remove_index :aliases, :name
        add_index :aliases, :name
      end
    
      dir.down do
        remove_index :aliases, :name
        add_index :aliases, :name, unique: true
      end
    end
  end
end
