FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    quantity { 2 }
    price { 10.0 }

    before(:create) do |order_item|
      order_item.price = order_item.product.price if order_item.price.nil? || order_item.price.zero?
    end
  end
end
