require 'rails_helper'

RSpec.describe Api::V1::ProductSerializer, type: :serializer do
  let(:product) { create(:product, name: 'Margherita Pizza', price: 15.50, active: true) }
  let(:serializer) { described_class.new(product) }
  let(:serialization) { serializer.serializable_hash }

  it 'serializes product attributes correctly' do
    data = serialization[:data]

    expect(data[:id]).to eq(product.id.to_s)
    expect(data[:type]).to eq(:product)
    expect(data[:attributes]).to eq({
      name: 'Margherita Pizza',
      active: true,
      price: BigDecimal('15.50')
    })
  end
end
