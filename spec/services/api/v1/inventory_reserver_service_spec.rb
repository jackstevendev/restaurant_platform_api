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

    context 'under concurrent race conditions (pessimistic locking)' do
      let(:product_concurrent) { create(:product, restaurant: restaurant, name: 'Last Steak') }
      let!(:inventory_concurrent) { create(:inventory_item, product: product_concurrent, quantity: 1) }

      it 'allows only ONE request to succeed and rejects the second with InsufficientInventory' do
        items = [{ product_id: product_concurrent.id, quantity: 1 }]
        products_map = { product_concurrent.id => product_concurrent }

        results = []
        errors = []
        mutex = Mutex.new

        threads = 2.times.map do
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              described_class.call(restaurant, items, products_map)
              mutex.synchronize { results << :success }
            rescue Errors::InsufficientInventory => e
              mutex.synchronize { errors << e }
            end
          end
        end

        threads.each(&:join)

        expect(results.count).to eq(1)
        expect(errors.count).to eq(1)
        expect(inventory_concurrent.reload.quantity).to eq(0)
      end
    end
  end
end
