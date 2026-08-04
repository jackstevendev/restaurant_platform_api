class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.string :provider
      t.string :transaction_id
      t.decimal :amount, precision: 10, scale: 2
      t.string :status

      t.timestamps
    end

    add_index :payments, :transaction_id, unique: true
  end
end
