class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.uuid :public_id
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
    add_index :orders, :public_id, unique: true
  end
end
