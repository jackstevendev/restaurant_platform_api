require 'rails_helper'

RSpec.describe Api::V1::OrderSerializer, type: :serializer do
  let(:customer) { create(:customer) }
  let(:order) { create(:order, customer: customer, status: :paid, total: 100.0) }
  let!(:payment) { create(:payment, order: order, amount: 100.0) }
  let!(:order_item) { create(:order_item, order: order, price: 50.0, quantity: 2) }

  describe 'serialization' do
    let(:serializer) { described_class.new(order, include: [:customer, :payment, :order_items]) }
    let(:serialization) { serializer.serializable_hash }

    it 'serializes order attributes' do
      data = serialization[:data]

      expect(data[:id]).to eq(order.id.to_s)
      expect(data[:type]).to eq(:order)
      expect(data[:attributes][:public_id]).to eq(order.public_id)
      expect(data[:attributes][:status]).to eq('paid')
      expect(data[:attributes][:total]).to eq(BigDecimal('100.0'))
      expect(data[:attributes]).to have_key(:created_at)
      expect(data[:attributes]).to have_key(:updated_at)
    end

    it 'includes relationships structure' do
      data = serialization[:data]
      relationships = data[:relationships]

      expect(relationships).to have_key(:customer)
      expect(relationships).to have_key(:payment)
      expect(relationships).to have_key(:order_items)
    end

    it 'includes side-loaded records when include option is passed' do
      included = serialization[:included]
      included_types = included.map { |item| item[:type] }

      expect(included_types).to include(:customer, :payment, :order_item)
    end
  end
end
