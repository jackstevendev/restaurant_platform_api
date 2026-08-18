require 'rails_helper'

RSpec.describe Api::V1::PaymentSerializer, type: :serializer do
  let(:payment) do
    create(:payment,
           provider: 'stripe',
           amount: 88.00,
           status: :approved,
           transaction_id: 'txn_123456789')
  end
  let(:serializer) { described_class.new(payment) }
  let(:serialization) { serializer.serializable_hash }

  it 'serializes payment attributes correctly' do
    data = serialization[:data]

    expect(data[:id]).to eq(payment.id.to_s)
    expect(data[:type]).to eq(:payment)
    expect(data[:attributes]).to eq({
      provider: 'stripe',
      amount: BigDecimal('88.00'),
      status: 'approved',
      transaction_id: 'txn_123456789'
    })
  end
end
