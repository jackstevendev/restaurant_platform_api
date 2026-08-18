require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:order_items).dependent(:destroy) }
    it { is_expected.to have_one(:payment).dependent(:destroy) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(
          pending: 'pending',
          paid: 'paid',
          cancelled: 'cancelled',
          completed: 'completed'
        )
        .backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(0) }
  end

  describe 'cascading deletes' do
    it 'destroys associated order_items and payment when order is destroyed' do
      order = create(:order)
      order_item = create(:order_item, order: order)
      payment = create(:payment, order: order)

      expect { order.destroy }
        .to change(OrderItem, :count).by(-1)
        .and change(Payment, :count).by(-1)

      expect(OrderItem.find_by(id: order_item.id)).to be_nil
      expect(Payment.find_by(id: payment.id)).to be_nil
    end
  end
end
