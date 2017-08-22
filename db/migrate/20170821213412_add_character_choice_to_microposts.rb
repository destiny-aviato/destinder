class AddCharacterChoiceToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :character_choice, :string
  end
end
