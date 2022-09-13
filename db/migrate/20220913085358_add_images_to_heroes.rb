class AddImagesToHeroes < ActiveRecord::Migration[7.0]
  def change
    add_column :heroes, :image, :string
    add_column :heroes, :icon,  :string
  end
end
