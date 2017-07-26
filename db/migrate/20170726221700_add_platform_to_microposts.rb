class AddPlatformToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :platform, :string
    add_column :microposts, :raid_difficulty, :string
  end
end
