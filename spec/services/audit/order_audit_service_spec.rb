require 'rails_helper'

RSpec.describe Audit::OrderAuditService do
  let(:restaurant) { create(:restaurant) }
  let(:customer) { create(:customer) }
  let(:product) { create(:product, restaurant: restaurant, price: 20.00) }
  let(:order) { create(:order, customer: customer, total: 40.00) }
  let!(:order_item) { create(:order_item, order: order, product: product, price: 20.00, quantity: 2) }

  describe '.call' do
    context 'when MongoDB is accessible' do
      let(:mock_collection) { double('audit_collection') }

      before do
        allow(MongoDatabase).to receive(:audit_collection).and_return(mock_collection)
      end

      it 'inserts an ORDER_CREATED audit document with correct metadata' do
        expect(mock_collection).to receive(:insert_one) do |doc|
          expect(doc[:event]).to eq('ORDER_CREATED')
          expect(doc[:order_id]).to eq(order.id.to_s)
          expect(doc[:customer_id]).to eq(customer.id.to_s)
          expect(doc[:restaurant_id]).to eq(restaurant.id.to_s)
          expect(doc[:total]).to eq(40.00)
          expect(doc[:items_count]).to eq(2)
          expect(doc[:created_at]).to be_a(Time)
        end

        result = described_class.call(order)
        expect(result).to be_present
        expect(result[:event]).to eq('ORDER_CREATED')
      end
    end

    context 'when MongoDB fails with a connection or write error' do
      let(:mock_collection) { double('audit_collection') }

      before do
        allow(MongoDatabase).to receive(:audit_collection).and_return(mock_collection)
        allow(mock_collection).to receive(:insert_one).and_raise(Mongo::Error::SocketError.new('Connection refused'))
      end

      it 'catches the exception, logs error, and does not propagate failure' do
        expect(Rails.logger).to receive(:error).with(/Error recording MongoDB audit event/)

        expect {
          result = described_class.call(order)
          expect(result).to be_nil
        }.not_to raise_error
      end
    end
  end
end
