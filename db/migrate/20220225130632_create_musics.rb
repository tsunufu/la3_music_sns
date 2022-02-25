class CreateMusics < ActiveRecord::Migration[6.1]
  def change
    create_table :musics do |t|
      t.string :img
      t.string :artist
      t.string :album
      t.string :name
      t.string :sample
      t.text :comment
      t.string :user_id
      t.timestamps null: false
    end
  end
end
