class AddDateToPatch < ActiveRecord::Migration[7.0]
  def change
    add_column :patches, :date, :datetime
  end
end
