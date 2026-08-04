class CreateInventoryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_items, id: :uuid do |t|
      t.references :product, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.integer :quantity, default: 0, null: false
      t.integer :minimum_stock, default: 5, null: false

      t.timestamps
    end

    add_check_constraint(
      :inventory_items,
      "quantity >= 0",
      name: "quantity_positive"
    )
  end
end
