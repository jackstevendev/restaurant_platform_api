FactoryBot.define do
  factory :payment do
    association :order
    amount { 50.0 }
    provider { "stripe" }
    status { :pending }
    sequence(:transaction_id) { |n| "txn_#{SecureRandom.hex(8)}_#{n}" }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
