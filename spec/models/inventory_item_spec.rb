require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:product) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:minimum_stock).is_greater_than_or_equal_to(0) }
  end

  describe 'defaults and constraints' do
    it 'creates valid inventory item with default values' do
      product = create(:product)
      inventory_item = InventoryItem.create!(product: product)

      expect(inventory_item.quantity).to eq(0)
      expect(inventory_item.minimum_stock).to eq(5)
    end

    it 'does not allow negative quantity at validation level' do
      inventory_item = build(:inventory_item, quantity: -1)
      expect(inventory_item).not_to be_valid
      expect(inventory_item.errors[:quantity]).to be_present
    end
  end

  describe '.below_minimum_stock' do
    let(:restaurant) { create(:restaurant) }

    context 'when quantity is less than minimum_stock' do
      let!(:item) { create(:product, :with_inventory, restaurant: restaurant, quantity: 2, minimum_stock: 5).inventory_item }

      it 'includes the item in the scope' do
        expect(described_class.below_minimum_stock).to include(item)
      end
    end

    context 'when quantity equals minimum_stock (boundary)' do
      let!(:item) { create(:product, :with_inventory, restaurant: restaurant, quantity: 5, minimum_stock: 5).inventory_item }

      it 'includes the item in the scope (boundary also triggers alert)' do
        expect(described_class.below_minimum_stock).to include(item)
      end
    end

    context 'when quantity is greater than minimum_stock' do
      let!(:item) { create(:product, :with_inventory, restaurant: restaurant, quantity: 10, minimum_stock: 5).inventory_item }

      it 'does NOT include the item in the scope' do
        expect(described_class.below_minimum_stock).not_to include(item)
      end
    end

    context 'when quantity is 0 (out of stock)' do
      let!(:item) { create(:product, :with_inventory, restaurant: restaurant, quantity: 0, minimum_stock: 5).inventory_item }

      it 'includes the item in the scope' do
        expect(described_class.below_minimum_stock).to include(item)
      end
    end
  end
end

