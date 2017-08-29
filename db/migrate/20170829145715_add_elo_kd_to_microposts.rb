class AddEloKdToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :elo, :integer
    add_column :microposts, :kd, :float
  end
end
