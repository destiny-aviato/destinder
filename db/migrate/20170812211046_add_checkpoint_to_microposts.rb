class AddCheckpointToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :checkpoint, :string
  end
end
