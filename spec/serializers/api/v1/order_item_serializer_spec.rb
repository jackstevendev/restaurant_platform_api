require 'rails_helper'

RSpec.describe Api::V1::OrderItemSerializer, type: :serializer do
  let(:product) { create(:product, price: 12.50) }
  let(:order) { create(:order) }
  let(:order_item) { create(:order_item, order: order, product: product, price: 12.50, quantity: 3) }
  let(:serializer) { described_class.new(order_item, include: [:product]) }
  let(:serialization) { serializer.serializable_hash }

  it 'serializes order item attributes and calculates subtotal' do
    data = serialization[:data]

    expect(data[:id]).to eq(order_item.id.to_s)
    expect(data[:type]).to eq(:order_item)
    expect(data[:attributes][:quantity]).to eq(3)
    expect(data[:attributes][:price]).to eq(BigDecimal('12.50'))
    expect(data[:attributes][:subtotal]).to eq(BigDecimal('37.50'))
  end

  it 'includes product relationship' do
    data = serialization[:data]
    expect(data[:relationships]).to have_key(:product)

    included = serialization[:included]
    expect(included.first[:type]).to eq(:product)
    expect(included.first[:id]).to eq(product.id.to_s)
  end
end
