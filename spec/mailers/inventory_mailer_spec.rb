require 'rails_helper'

RSpec.describe InventoryMailer, type: :mailer do
  describe '#low_stock_alert' do
    let(:restaurant) { create(:restaurant, name: 'Bistro Test', email: 'admin@bistro.com') }
    let(:product)    { create(:product, :with_inventory, restaurant: restaurant, quantity: 2, minimum_stock: 5) }
    let(:low_stock_items) { [ product.inventory_item ] }
    let(:mail) { described_class.low_stock_alert(restaurant, low_stock_items) }

    it 'is sent to the restaurant email address' do
      expect(mail.to).to eq([ 'admin@bistro.com' ])
    end

    it 'includes the restaurant name in the subject' do
      expect(mail.subject).to include('Bistro Test')
    end

    it 'includes the alert emoji in the subject' do
      expect(mail.subject).to include('⚠️')
    end

    it 'includes the product name in the text body' do
      expect(mail.text_part.body.decoded).to include(product.name)
    end

    it 'includes current stock and minimum stock in the text body' do
      body = mail.text_part.body.decoded
      expect(body).to include('2')
      expect(body).to include('5')
    end

    it 'includes the product name in the HTML body' do
      expect(mail.html_part.body.decoded).to include(product.name)
    end
  end
end
