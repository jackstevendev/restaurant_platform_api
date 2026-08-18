require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:restaurant) }
    it { is_expected.to have_one(:inventory_item).dependent(:destroy) }
    it { is_expected.to have_many(:order_items).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than(0) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active products' do
        active_product = create(:product, active: true)
        inactive_product = create(:product, active: false)

        expect(Product.active).to include(active_product)
        expect(Product.active).not_to include(inactive_product)
      end
    end
  end

  describe 'behavior' do
    it 'destroys associated inventory_item when product is destroyed' do
      product = create(:product)
      inventory_item = create(:inventory_item, product: product)

      expect { product.destroy }.to change(InventoryItem, :count).by(-1)
      expect(InventoryItem.find_by(id: inventory_item.id)).to be_nil
    end

    it 'raises error when attempting to delete product with associated order_items' do
      product = create(:product)
      order = create(:order)
      create(:order_item, product: product, order: order)

      expect { product.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
