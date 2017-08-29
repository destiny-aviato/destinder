class AddMinMaxToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :elo_min, :string
    add_column :microposts, :elo_max, :string
    add_column :microposts, :kd_min, :string
    add_column :microposts, :kd_max, :string
  end
end
