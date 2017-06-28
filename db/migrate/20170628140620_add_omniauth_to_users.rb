class AddOmniauthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provider, :string
    add_index :users, :provider
    add_column :users, :uid, :string
    add_index :users, :uid
    add_column :users, :membership_id, :string
    add_column :users, :display_name, :string
    add_column :users, :unique_name, :string
  end
end
