FactoryBot.define do
  factory :product do
    association :restaurant
    name { Faker::Food.dish }
    price { Faker::Commerce.price(range: 5.0..50.0) }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :with_inventory do
      transient do
        quantity { 10 }
        minimum_stock { 5 }
      end

      after(:create) do |product, evaluator|
        create(:inventory_item, product: product, quantity: evaluator.quantity, minimum_stock: evaluator.minimum_stock)
      end
    end
  end
end
