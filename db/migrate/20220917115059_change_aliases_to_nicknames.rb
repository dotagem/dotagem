class ChangeAliasesToNicknames < ActiveRecord::Migration[7.0]
  def change
    rename_table :aliases, :nicknames
  end
end
