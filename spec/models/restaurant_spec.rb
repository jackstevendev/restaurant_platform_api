require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:products).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'creation and cascading deletes' do
    it 'creates a valid restaurant with factory' do
      restaurant = build(:restaurant)
      expect(restaurant).to be_valid
    end

    it 'destroys associated products when restaurant is destroyed' do
      restaurant = create(:restaurant)
      product = create(:product, restaurant: restaurant)

      expect { restaurant.destroy }.to change(Product, :count).by(-1)
      expect(Product.find_by(id: product.id)).to be_nil
    end
  end
end
