FactoryBot.define do
  factory :subscription do
    price { 1000 }
    subscription_name { "Netflix" }
    plan_name { "スタンダード" }
    start_date { Time.zone.today }
    end_date { 1.months.from_now.to_date }
    billing_date { 1.months.from_now.to_date }
    user
  end
end
