require 'rails_helper'

RSpec.describe Api::V1::InventoryReserverService do
  let(:restaurant) { create(:restaurant) }
  let(:product1) { create(:product, restaurant: restaurant, name: 'Burger') }
  let!(:inventory1) { create(:inventory_item, product: product1, quantity: 10) }
  let(:product2) { create(:product, restaurant: restaurant, name: 'Fries') }
  let!(:inventory2) { create(:inventory_item, product: product2, quantity: 5) }

  let(:products_map) do
    {
      product1.id => product1,
      product2.id => product2
    }
  end

  describe '.call' do
    context 'when sufficient inventory is available' do
      let(:items) do
        [
          { product_id: product1.id, quantity: 3 },
          { product_id: product2.id, quantity: 5 }
        ]
      end

      it 'decreases the inventory quantities correctly' do
        described_class.call(restaurant, items, products_map)

        expect(inventory1.reload.quantity).to eq(7)
        expect(inventory2.reload.quantity).to eq(0)
      end
    end

    context 'when insufficient inventory is available' do
      let(:items) do
        [
          { product_id: product1.id, quantity: 15 }
        ]
      end

      it 'raises Errors::InsufficientInventory with item name' do
        expect {
          described_class.call(restaurant, items, products_map)
        }.to raise_error(Errors::InsufficientInventory, 'Insufficient inventory for Burger')

        expect(inventory1.reload.quantity).to eq(10)
      end
    end

    context 'when stock becomes insufficient on a subsequent item' do
      let(:items) do
        [
          { product_id: product1.id, quantity: 2 },
          { product_id: product2.id, quantity: 99 }
        ]
      end

      it 'raises error when encountering item without enough stock' do
        expect {
          described_class.call(restaurant, items, products_map)
        }.to raise_error(Errors::InsufficientInventory, 'Insufficient inventory for Fries')
      end
    end

    context 'when a product does not belong to the restaurant' do
      let(:items) do
        [
          { product_id: SecureRandom.uuid, quantity: 1 }
        ]
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.call(restaurant, items, products_map)
        }.to raise_error(ActiveRecord::RecordNotFound, 'Product not found for this restaurant')
      end
    end
  end
end
