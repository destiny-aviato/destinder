class AddStatsDataToPlayerStats < ActiveRecord::Migration[5.0]
  def change
    add_column :player_stats, :stats_data, :string
  end
end
