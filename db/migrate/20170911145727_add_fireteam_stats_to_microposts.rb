class AddFireteamStatsToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :fireteam_stats, :text
  end
end
