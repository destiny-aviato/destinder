class AddFieldsToTeamStat < ActiveRecord::Migration[5.0]
  def change
    add_column :team_stats, :membership_type, :string
    add_column :team_stats, :stats_data, :text
    add_column :team_stats, :characters, :text
    add_column :team_stats, :display_name, :text
  end
end
