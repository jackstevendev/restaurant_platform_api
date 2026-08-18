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
end
