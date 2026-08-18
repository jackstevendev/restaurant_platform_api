FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    sequence(:email) { |n| "customer_#{n}@example.com" }
    phone { Faker::PhoneNumber.phone_number }
  end
end
