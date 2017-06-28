class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profile_picture, :string
    add_column :users, :about, :string
    add_column :users, :xbox_display_name, :string
    add_column :users, :psn_display_name, :string
  end
end
