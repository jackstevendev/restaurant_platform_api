FactoryBot.define do
  factory :report do
    file_url { "https://example.com/reports/monthly_#{SecureRandom.hex(4)}.pdf" }
    status { "pending" }
  end
end
