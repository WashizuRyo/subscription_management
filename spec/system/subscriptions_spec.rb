require "rails_helper"

RSpec.describe "Subscriptions", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:subscription) { FactoryBot.create(:subscription, user: user) }


  it "user redirect to root_path when access to other user /uses/:id/subscriptions/new" do
    login_as user

    visit new_user_subscription_path(other_user)

    aggregate_failures do
      expect(page).to have_content "権限がありません"
      expect(page).to have_current_path root_path
    end
  end

  it "displays '登録されたサブスクリプションはありません' and new links on the index page" do
    login_as user

    visit user_subscriptions_path(user)

    aggregate_failures do
      expect(page).to have_content "登録されたサブスクリプションはありません"
      expect(page).to have_link("新規作成", href: new_user_subscription_path(user))
    end
  end

  def fill_in_subscription_form(price = 1000,
    name = "Netflix",
    plan = "スタンダード",
    start_date = Time.zone.today,
    end_date = 1.months.from_now.to_date,
    billing_day_of_month = 1.months.from_now.to_date)
    fill_in "料金", with: price
    fill_in "サブスクリプション名", with: name
    fill_in "プラン名", with: plan
    fill_in "開始日", with: start_date
    fill_in "終了日", with: end_date
    fill_in "毎月の請求日", with: billing_day_of_month
  end

  # it "displays 'サブスクリプションを削除しました' when subscription deleted" do
  #   subscription
  #   login_as user

  #   visit user_subscriptions_path(user)

  #   expect do
  #     expect(page).to have_content subscription.name
  #     click_button "削除"
  #     expect(page).to have_content "サブスクリプションを削除しました"
  #     expect(page).to_not have_content subscription.name
  #   end.to change(Subscription, :count).by(-1)
  # end
end
