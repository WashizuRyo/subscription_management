FactoryBot.define do
  factory :payment_method do
    sequence(:method_type) { |n| "method_type#{n}" }
    provider { "test_provider" }
    memo { "test_memo" }
    user
  end
end
