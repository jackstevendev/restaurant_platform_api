require 'rails_helper'

RSpec.describe Inventory::LowStockAlertService do
  describe '#call' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    context 'when a restaurant with an email has products below minimum stock' do
      let!(:restaurant) { create(:restaurant, email: 'admin@bistro.com') }
      let!(:low_product)  { create(:product, :with_inventory, restaurant: restaurant, quantity: 2, minimum_stock: 5) }
      let!(:ok_product)   { create(:product, :with_inventory, restaurant: restaurant, quantity: 20, minimum_stock: 5) }

      it 'sends one email to the restaurant' do
        expect { described_class.call }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'sends the email to the restaurant email address' do
        described_class.call
        expect(ActionMailer::Base.deliveries.last.to).to eq([ 'admin@bistro.com' ])
      end

      it 'includes only low-stock products in the email, not the healthy ones' do
        described_class.call
        body = ActionMailer::Base.deliveries.last.text_part.body.decoded
        expect(body).to include(low_product.name)
        expect(body).not_to include(ok_product.name)
      end

      it 'includes the restaurant name in the subject' do
        described_class.call
        expect(ActionMailer::Base.deliveries.last.subject).to include(restaurant.name)
      end
    end

    context 'when a product stock equals minimum_stock exactly (boundary)' do
      let!(:restaurant) { create(:restaurant, email: 'admin@bistro.com') }
      let!(:boundary_product) { create(:product, :with_inventory, restaurant: restaurant, quantity: 5, minimum_stock: 5) }

      it 'sends the alert (boundary level also triggers alert)' do
        expect { described_class.call }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when the restaurant has no email configured' do
      let!(:restaurant) { create(:restaurant, email: nil) }
      let!(:low_product) { create(:product, :with_inventory, restaurant: restaurant, quantity: 1, minimum_stock: 5) }

      it 'does not send any email' do
        expect { described_class.call }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(a_string_including(restaurant.id.to_s))
        described_class.call
      end
    end

    context 'when all products have sufficient stock' do
      let!(:restaurant) { create(:restaurant, email: 'admin@bistro.com') }
      let!(:ok_product)  { create(:product, :with_inventory, restaurant: restaurant, quantity: 20, minimum_stock: 5) }

      it 'does not send any email' do
        expect { described_class.call }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'when multiple restaurants have low stock products' do
      let!(:restaurant_a) { create(:restaurant, email: 'a@example.com') }
      let!(:restaurant_b) { create(:restaurant, email: 'b@example.com') }
      let!(:product_a) { create(:product, :with_inventory, restaurant: restaurant_a, quantity: 1, minimum_stock: 5) }
      let!(:product_b) { create(:product, :with_inventory, restaurant: restaurant_b, quantity: 0, minimum_stock: 5) }

      it 'sends one digest email per restaurant (not one per product)' do
        expect { described_class.call }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end

    context 'when the mailer fails for one restaurant' do
      let!(:restaurant_a) { create(:restaurant, email: 'a@example.com') }
      let!(:restaurant_b) { create(:restaurant, email: 'b@example.com') }
      let!(:product_a) { create(:product, :with_inventory, restaurant: restaurant_a, quantity: 1, minimum_stock: 5) }
      let!(:product_b) { create(:product, :with_inventory, restaurant: restaurant_b, quantity: 1, minimum_stock: 5) }

      it 'continues processing the remaining restaurants' do
        # Stub by restaurant identity rather than call order to avoid
        # fragility if the query changes its result ordering.
        allow(InventoryMailer).to receive(:low_stock_alert).and_wrap_original do |m, restaurant, items|
          raise StandardError, 'SMTP error' if restaurant == restaurant_a

          m.call(restaurant, items)
        end

        expect { described_class.call }.not_to raise_error
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'when a product is inactive but has low stock' do
      let!(:restaurant) { create(:restaurant, email: 'admin@bistro.com') }
      let!(:inactive_product) do
        create(:product, :inactive, :with_inventory, restaurant: restaurant, quantity: 1, minimum_stock: 5)
      end

      it 'includes the inactive product in the alert (scope does not filter by active)' do
        expect { described_class.call }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'mentions the inactive product in the email body' do
        described_class.call
        body = ActionMailer::Base.deliveries.last.text_part.body.decoded
        expect(body).to include(inactive_product.name)
      end
    end
  end
end

