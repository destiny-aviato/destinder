class AddDestinyVersionToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :destiny_version, :string
  end
end
