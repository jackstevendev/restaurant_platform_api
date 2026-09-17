FactoryBot.define do
  factory :restaurant do
    name { Faker::Restaurant.name }
    address { Faker::Address.full_address }
    email { nil }

    trait :with_email do
      email { Faker::Internet.email }
    end
  end
end
