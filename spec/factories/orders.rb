FactoryBot.define do
  factory :order do
    association :customer
    status { :pending }
    total { 0.0 }
    public_id { SecureRandom.uuid }

    trait :paid do
      status { :paid }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :completed do
      status { :completed }
    end

    trait :with_items do
      transient do
        items_count { 2 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, order: order)
        order.update!(total: order.order_items.sum { |i| i.price * i.quantity })
      end
    end
  end
end
