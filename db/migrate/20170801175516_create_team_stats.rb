class CreateTeamStats < ActiveRecord::Migration[5.0]
  def change
    create_table :team_stats do |t|
      t.string :membership_type
      t.text :stats_data
      t.text :characters
      t.text :display_name

      t.timestamps
    end
  end
end
