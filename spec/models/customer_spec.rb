require 'rails_helper'

RSpec.describe Customer, type: :model do
  subject { build(:customer) }

  describe 'associations' do
    it { is_expected.to have_many(:orders).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }

    it 'accepts valid email formats' do
      valid_emails = ['user@example.com', 'first.last@domain.co', 'user+tag@domain.org']
      valid_emails.each do |email|
        customer = build(:customer, email: email)
        expect(customer).to be_valid
      end
    end

    it 'rejects invalid email formats' do
      invalid_emails = ['plainaddress', '@missingusername.com', 'user@domain,com', 'user@domain.']
      invalid_emails.each do |email|
        customer = build(:customer, email: email)
        expect(customer).not_to be_valid
        expect(customer.errors[:email]).to be_present
      end
    end
  end

  describe 'behavior' do
    it 'raises error when attempting to delete customer with associated orders' do
      customer = create(:customer)
      create(:order, customer: customer)

      expect { customer.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
