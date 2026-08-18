FactoryBot.define do
  factory :restaurant do
    name { Faker::Restaurant.name }
    address { Faker::Address.full_address }
  end
end
