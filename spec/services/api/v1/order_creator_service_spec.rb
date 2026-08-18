require 'rails_helper'

RSpec.describe Api::V1::OrderCreatorService do
  let(:restaurant) { create(:restaurant) }
  let(:customer) { create(:customer) }
  let(:product1) { create(:product, restaurant: restaurant, price: 15.00) }
  let(:product2) { create(:product, restaurant: restaurant, price: 5.50) }

  let(:products_map) do
    {
      product1.id => product1,
      product2.id => product2
    }
  end

  let(:order_params) do
    {
      customer_id: customer.id,
      order_items: [
        { product_id: product1.id, quantity: 2 },
        { product_id: product2.id, quantity: 3 }
      ]
    }
  end

  describe '.call' do
    it 'creates an order and persists associated order items with calculated total' do
      order = nil
      expect {
        order = described_class.call(restaurant, order_params, products_map)
      }.to change(Order, :count).by(1).and change(OrderItem, :count).by(2)

      expect(order).to be_persisted
      expect(order.customer).to eq(customer)
      expect(order.order_items.count).to eq(2)
      # total: (15.00 * 2) + (5.50 * 3) = 30.00 + 16.50 = 46.50
      expect(order.total).to eq(BigDecimal('46.50'))

      item1 = order.order_items.find_by(product_id: product1.id)
      expect(item1.quantity).to eq(2)
      expect(item1.price).to eq(BigDecimal('15.00'))

      item2 = order.order_items.find_by(product_id: product2.id)
      expect(item2.quantity).to eq(3)
      expect(item2.price).to eq(BigDecimal('5.50'))
    end

    it 'raises validation error when customer_id is invalid' do
      invalid_params = order_params.merge(customer_id: SecureRandom.uuid)

      expect {
        described_class.call(restaurant, invalid_params, products_map)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'raises ActiveRecord::RecordNotFound when product is not in products map' do
      invalid_params = order_params.merge(order_items: [{ product_id: SecureRandom.uuid, quantity: 1 }])

      expect {
        described_class.call(restaurant, invalid_params, products_map)
      }.to raise_error(ActiveRecord::RecordNotFound, 'Product not found for this restaurant')
    end
  end
end
