class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants, id: :uuid do |t|
      t.string :name, null: false
      t.string :address

      t.timestamps
    end

    add_index :restaurants, :name
  end
end
