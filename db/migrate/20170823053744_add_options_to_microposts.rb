class AddOptionsToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :mic_required, :boolean
    add_column :microposts, :looking_for, :string
  end
end
