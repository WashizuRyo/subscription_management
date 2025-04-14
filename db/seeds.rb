# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(name: "Tester",
             email: "tester@example.com",
             password: "password",
             password_confirmation: "password"
)

user = User.first
subscriptions = [
  {
    subscription_name: "Netflix",
    plan_name: "スタンダード",
    price: 1490,
    start_date: Date.today - 2.months,
    end_date: Date.today + 10.months,
    billing_date: Date.today.beginning_of_month
  },
  {
    subscription_name: "Amazon Prime",
    plan_name: "年間プラン",
    price: 4900,
    start_date: Date.today - 3.months,
    end_date: Date.today + 9.months,
    billing_date: Date.today - 3.months
  },
  {
    subscription_name: "Spotify",
    plan_name: "プレミアム",
    price: 980,
    start_date: Date.today - 1.month,
    end_date: Date.today + 11.months,
    billing_date: Date.today.beginning_of_month
  }
]

subscriptions.each do |subscription_data|
  user.subscriptions.create!(subscription_data)
end
