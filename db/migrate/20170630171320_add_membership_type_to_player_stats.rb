class AddMembershipTypeToPlayerStats < ActiveRecord::Migration[5.0]
  def change
    add_column :player_stats, :membership_type, :string
  end
end
