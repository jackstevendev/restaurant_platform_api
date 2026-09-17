require 'rails_helper'

RSpec.describe OrderInvoiceJob, type: :job do
  include ActiveJob::TestHelper

  let(:restaurant) { create(:restaurant) }
  let(:customer) { create(:customer, email: 'customer@example.com') }
  let(:product) { create(:product, restaurant: restaurant, price: 50.00) }
  let(:order) { create(:order, customer: customer, total: 50.00) }
  let!(:order_item) { create(:order_item, order: order, product: product, price: 50.00, quantity: 1) }

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
    ActionMailer::Base.deliveries.clear
  end

  describe '#perform' do
    it 'finds order in PostgreSQL, generates invoice, uploads to S3 and delivers confirmation email' do
      expect(Invoices::InvoiceGeneratorService).to receive(:call).with(order).and_call_original
      expect(Storage::S3UploaderService).to receive(:call).with(anything, "invoices/#{order.id}.pdf").and_call_original

      expect {
        described_class.perform_now(order.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      sent_mail = ActionMailer::Base.deliveries.last
      expect(sent_mail.to).to eq(['customer@example.com'])
      expect(sent_mail.text_part.body.decoded).to include("https://restaurant-platform-invoices.s3.us-east-1.amazonaws.com/invoices/#{order.id}.pdf")
    end

    describe 'idempotency' do
      it 'does NOT send duplicate emails or regenerate invoice when executed multiple times (retries)' do
        # First execution
        described_class.perform_now(order.id)
        expect(ActionMailer::Base.deliveries.count).to eq(1)

        # Second execution (e.g. Sidekiq retry or duplicate delivery)
        expect(Invoices::InvoiceGeneratorService).not_to receive(:call)
        expect(Storage::S3UploaderService).not_to receive(:call)

        expect {
          described_class.perform_now(order.id)
        }.not_to change { ActionMailer::Base.deliveries.count }

        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    describe 'error handling' do
      it 'safely discards job without raising error when order is not found in PostgreSQL' do
        expect {
          described_class.perform_now(SecureRandom.uuid)
        }.not_to raise_error
      end
    end

    describe 'queue configuration' do
      it 'enqueues job in the invoices queue' do
        expect {
          described_class.perform_later(order.id)
        }.to have_enqueued_job(described_class).with(order.id).on_queue('invoices')
      end
    end
  end
end
