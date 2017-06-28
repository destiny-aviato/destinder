class AddRequestDataToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :request_data, :string
  end
end
