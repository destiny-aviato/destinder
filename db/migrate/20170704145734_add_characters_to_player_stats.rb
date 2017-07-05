class AddCharactersToPlayerStats < ActiveRecord::Migration[5.0]
  def change
    add_column :player_stats, :characters, :text
  end
end
