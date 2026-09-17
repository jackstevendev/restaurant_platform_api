require 'rails_helper'

RSpec.describe Invoices::InvoiceGeneratorService do
  let(:restaurant) { create(:restaurant) }
  let(:customer) { create(:customer, name: 'Jane Doe', email: 'jane@example.com') }
  let(:product1) { create(:product, restaurant: restaurant, name: 'Pasta', price: 20.00) }
  let(:product2) { create(:product, restaurant: restaurant, name: 'Wine', price: 10.00) }
  let(:order) { create(:order, customer: customer) }
  let!(:item1) { create(:order_item, order: order, product: product1, price: 20.00, quantity: 2) }
  let!(:item2) { create(:order_item, order: order, product: product2, price: 10.00, quantity: 1) }

  describe '.call' do
    it 'generates a structured invoice data structure with totals and line items' do
      invoice = described_class.call(order)

      expect(invoice[:invoice_number]).to start_with('INV-')
      expect(invoice[:customer_name]).to eq('Jane Doe')
      expect(invoice[:customer_email]).to eq('jane@example.com')
      expect(invoice[:items].count).to eq(2)
      
      # subtotal = (20*2) + (10*1) = 50.00
      # tax (10%) = 5.00
      # total = 55.00
      expect(invoice[:subtotal]).to eq(50.00)
      expect(invoice[:tax]).to eq(5.00)
      expect(invoice[:total]).to eq(55.00)
      expect(invoice[:pdf_content]).to be_present
    end
  end
end
