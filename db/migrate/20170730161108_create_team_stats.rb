class CreateTeamStats < ActiveRecord::Migration[5.0]
  def change
    create_table :team_stats do |t|

      t.timestamps
    end
  end
end
