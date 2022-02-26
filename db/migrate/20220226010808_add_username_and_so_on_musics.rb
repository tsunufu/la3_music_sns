class AddUsernameAndSoOnMusics < ActiveRecord::Migration[6.1]
  def change
    add_column :musics, :user_name, :string
    add_column :musics, :user_icon, :string
  end
end
