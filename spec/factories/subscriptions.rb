FactoryBot.define do
  factory :subscription do
    price { 1000 }
    sequence(:subscription_name) { |n| "Subscription#{n}" }
    plan_name { "スタンダード" }
    start_date { Time.zone.today }
    end_date { 1.months.from_now.to_date }
    billing_date { 1.months.from_now.to_date }
    user
  end
end
