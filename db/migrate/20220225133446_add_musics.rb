class AddMusics < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :products, null: true 

    long_ago = DateTime.new(2000, 1, 1)
    Product.update_all(created_at: long_ago, updated_at: long_ago)

    change_column_null :products, :created_at, false
    change_column_null :products, :updated_at, false
  end
end
