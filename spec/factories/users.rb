FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "tester#{n}@example.com" }
    password { "password" }
  end

  trait :with_subscriptions do
    after(:create) { |user| create_list(:subscription, 5, user: user) }
  end

  trait :with_many_subscriptions do
    after(:create) { |user| create_list(:subscription, 20, user: user) }
  end

  trait :with_tags do
    after(:create) do |user|
      subscriptions = create_list(:subscription, 5, user: user)
      tags = create_list(:tag, 5)
      5.times do |i|
        create(:subscription_tag, subscription: subscriptions[i], tag: tags[i])
      end
    end
  end
end
