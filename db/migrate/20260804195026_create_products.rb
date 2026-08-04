class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :active, default: false, null: false
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end
    add_index :products, :name
  end
end
