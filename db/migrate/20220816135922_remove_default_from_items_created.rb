class RemoveDefaultFromItemsCreated < ActiveRecord::Migration[7.0]
  def change
    change_column_default :items, :created, nil
  end
end
