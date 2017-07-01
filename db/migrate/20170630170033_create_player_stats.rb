class CreatePlayerStats < ActiveRecord::Migration[5.0]
  def change
    create_table :player_stats do |t|
      t.string :display_name

      t.timestamps
    end
  end
end
