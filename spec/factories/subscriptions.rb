FactoryBot.define do
  factory :subscription do
    price { 1000 }
    sequence(:name) { |n| "Subscription#{n}" }
    plan { "スタンダード" }
    start_date { Time.zone.today }
    end_date { 1.months.from_now.to_date }
    billing_day_of_month { 1 }
    user
  end
end
