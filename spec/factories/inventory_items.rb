FactoryBot.define do
  factory :inventory_item do
    association :product
    quantity { 10 }
    minimum_stock { 5 }
  end
end
