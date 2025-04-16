FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "tester#{n}@example.com" }
    password { "password" }
  end

  trait :with_subscriptions do
    after(:create) { |user| create_list(:subscription, 5, user: user) }
  end
end
