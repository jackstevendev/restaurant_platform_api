require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:product) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
  end

  describe 'behavior' do
    it 'creates a valid order item with factory' do
      order_item = build(:order_item)
      expect(order_item).to be_valid
    end
  end
end
