class AddFireteamToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :fireteam, :text, array: true, default: []
  end
end
