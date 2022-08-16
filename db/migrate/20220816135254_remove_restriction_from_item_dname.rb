class RemoveRestrictionFromItemDname < ActiveRecord::Migration[7.0]
  def change
    change_column_null :items, :dname, true
  end
end
