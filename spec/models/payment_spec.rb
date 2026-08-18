require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(
          pending: 'pending',
          approved: 'approved',
          rejected: 'rejected'
        )
        .backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end
end
