require 'rails_helper'

RSpec.describe Api::V1::PricingService do
  describe '.calculate_total' do
    it 'calculates total price for a collection of order items' do
      item1 = instance_double(OrderItem, price: BigDecimal('10.50'), quantity: 2) # 21.00
      item2 = instance_double(OrderItem, price: BigDecimal('5.25'), quantity: 4)  # 21.00

      total = described_class.calculate_total([item1, item2])
      expect(total).to eq(BigDecimal('42.00'))
    end

    it 'returns 0 when order items list is empty' do
      total = described_class.calculate_total([])
      expect(total).to eq(0)
    end

    it 'handles single item calculations correctly' do
      item = instance_double(OrderItem, price: BigDecimal('19.99'), quantity: 3)
      total = described_class.calculate_total([item])
      expect(total).to eq(BigDecimal('59.97'))
    end
  end
end
