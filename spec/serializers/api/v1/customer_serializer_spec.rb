require 'rails_helper'

RSpec.describe Api::V1::CustomerSerializer, type: :serializer do
  let(:customer) { create(:customer, name: 'John Doe', email: 'john.doe@example.com', phone: '555-1234') }
  let(:serializer) { described_class.new(customer) }
  let(:serialization) { serializer.serializable_hash }

  it 'serializes customer attributes correctly' do
    data = serialization[:data]

    expect(data[:id]).to eq(customer.id.to_s)
    expect(data[:type]).to eq(:customer)
    expect(data[:attributes]).to eq({
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '555-1234'
    })
  end
end
