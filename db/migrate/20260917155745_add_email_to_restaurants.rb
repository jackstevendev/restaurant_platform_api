class AddEmailToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :email, :string
    add_index :restaurants, :email, unique: true
  end
end
