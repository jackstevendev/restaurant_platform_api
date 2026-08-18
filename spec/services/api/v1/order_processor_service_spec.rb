require 'rails_helper'

RSpec.describe Api::V1::OrderProcessorService do
  let(:restaurant) { create(:restaurant) }
  let(:customer) { create(:customer) }
  let(:product1) { create(:product, restaurant: restaurant, price: 20.00) }
  let!(:inventory1) { create(:inventory_item, product: product1, quantity: 10) }
  let(:product2) { create(:product, restaurant: restaurant, price: 10.00) }
  let!(:inventory2) { create(:inventory_item, product: product2, quantity: 4) }

  let(:order_params) do
    ActionController::Parameters.new(
      customer_id: customer.id,
      order_items: [
        { product_id: product1.id, quantity: 2 },
        { product_id: product2.id, quantity: 2 }
      ]
    ).permit(:customer_id, order_items: [:product_id, :quantity])
  end

  describe '.call' do
    context 'when order placement is successful' do
      it 'reserves inventory and creates order within transaction' do
        order = nil

        expect {
          order = described_class.call(restaurant.id, order_params)
        }.to change(Order, :count).by(1).and change(OrderItem, :count).by(2)

        expect(order).to be_persisted
        expect(order.total).to eq(BigDecimal('60.00'))
        expect(inventory1.reload.quantity).to eq(8)
        expect(inventory2.reload.quantity).to eq(2)
      end
    end

    context 'when inventory is insufficient' do
      let(:excessive_order_params) do
        ActionController::Parameters.new(
          customer_id: customer.id,
          order_items: [
            { product_id: product1.id, quantity: 2 },
            { product_id: product2.id, quantity: 10 } # only 4 available
          ]
        ).permit(:customer_id, order_items: [:product_id, :quantity])
      end

      it 'raises InsufficientInventory and rolls back inventory and order creation' do
        expect {
          described_class.call(restaurant.id, excessive_order_params)
        }.to raise_error(Errors::InsufficientInventory)

        expect(Order.count).to eq(0)
        expect(OrderItem.count).to eq(0)
        expect(inventory1.reload.quantity).to eq(10)
        expect(inventory2.reload.quantity).to eq(4)
      end
    end

    context 'when order creation fails after inventory reservation' do
      let(:invalid_order_params) do
        ActionController::Parameters.new(
          customer_id: SecureRandom.uuid, # non-existent customer
          order_items: [
            { product_id: product1.id, quantity: 2 }
          ]
        ).permit(:customer_id, order_items: [:product_id, :quantity])
      end

      it 'rolls back inventory changes when order creation raises error' do
        expect {
          described_class.call(restaurant.id, invalid_order_params)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(inventory1.reload.quantity).to eq(10)
        expect(Order.count).to eq(0)
      end
    end

    context 'when an order item belongs to a different restaurant' do
      let(:other_restaurant) { create(:restaurant) }
      let(:other_product) { create(:product, restaurant: other_restaurant, price: 15.00) }
      let!(:other_inventory) { create(:inventory_item, product: other_product, quantity: 10) }

      let(:cross_restaurant_order_params) do
        ActionController::Parameters.new(
          customer_id: customer.id,
          order_items: [
            { product_id: other_product.id, quantity: 1 }
          ]
        ).permit(:customer_id, order_items: [:product_id, :quantity])
      end

      it 'raises ActiveRecord::RecordNotFound and does not create an order' do
        expect {
          described_class.call(restaurant.id, cross_restaurant_order_params)
        }.to raise_error(ActiveRecord::RecordNotFound, 'Product not found for this restaurant')

        expect(Order.count).to eq(0)
        expect(other_inventory.reload.quantity).to eq(10)
      end
    end

    context 'under concurrent race conditions when stock is 1' do
      let(:exclusive_product) { create(:product, restaurant: restaurant, price: 30.00, name: 'Exclusive Plate') }
      let!(:exclusive_inventory) { create(:inventory_item, product: exclusive_product, quantity: 1) }

      let(:concurrent_params) do
        ActionController::Parameters.new(
          customer_id: customer.id,
          order_items: [
            { product_id: exclusive_product.id, quantity: 1 }
          ]
        ).permit(:customer_id, order_items: [:product_id, :quantity])
      end

      it 'allows exactly ONE order to be created and rejects the concurrent one with InsufficientInventory' do
        orders_created = []
        errors = []
        mutex = Mutex.new

        threads = 2.times.map do
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              order = described_class.call(restaurant.id, concurrent_params)
              mutex.synchronize { orders_created << order }
            rescue Errors::InsufficientInventory => e
              mutex.synchronize { errors << e }
            end
          end
        end

        threads.each(&:join)

        expect(orders_created.count).to eq(1)
        expect(errors.count).to eq(1)
        expect(exclusive_inventory.reload.quantity).to eq(0)
        expect(Order.where(total: 30.00).count).to eq(1)
      end
    end

    context 'when restaurant does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.call(SecureRandom.uuid, order_params)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
