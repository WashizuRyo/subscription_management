FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "tester#{n}@example.com" }
  end
end
