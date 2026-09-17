require 'rails_helper'

RSpec.describe OrderMailer, type: :mailer do
  let(:customer) { create(:customer, name: 'Alice Smith', email: 'alice@example.com') }
  let(:order) { create(:order, customer: customer, total: 75.00) }
  let(:product) { create(:product, name: 'Ribeye Steak', price: 75.00) }
  let!(:order_item) { create(:order_item, order: order, product: product, price: 75.00, quantity: 1) }
  let(:invoice_url) { 'https://restaurant-platform-invoices.s3.us-east-1.amazonaws.com/invoices/inv-123.pdf' }

  describe '#order_confirmation' do
    let(:mail) { described_class.order_confirmation(order, invoice_url) }

    it 'renders the headers' do
      expect(mail.subject).to include("Confirmación de Orden ##{order.id.to_s[0..7].upcase}")
      expect(mail.to).to eq(['alice@example.com'])
      expect(mail.from).to be_present
    end

    it 'renders customer name, order details and invoice URL in the body' do
      expect(mail.text_part.body.decoded).to include('Alice Smith')
      expect(mail.text_part.body.decoded).to include('Ribeye Steak')
      expect(mail.text_part.body.decoded).to include(invoice_url)

      expect(mail.html_part.body.decoded).to include('Alice Smith')
      expect(mail.html_part.body.decoded).to include('Ribeye Steak')
      expect(mail.html_part.body.decoded).to include(invoice_url)
    end
  end
end
