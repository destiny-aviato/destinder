class AddGameTypeToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :game_type, :string
    add_column :microposts, :user_stats, :text
  end
end
