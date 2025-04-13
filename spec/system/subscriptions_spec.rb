require 'rails_helper'

RSpec.describe "Subscriptions", type: :system do
  let(:user) { FactoryBot.create(:user) }

  it "user can create subscription" do
    login_as user

    visit new_user_subscription_path(user)

    fill_in "値段", with: 1000
    fill_in "名前", with: "Netflix"
    fill_in "プラン名", with: "スタンダード"
    fill_in "開始日", with: Time.zone.now
    fill_in "終了日", with: 1.months.from_now
    fill_in "請求日", with: 1.months.from_now

    click_button "送信する"

    aggregate_failures do
      expect(page).to have_current_path "/"
      expect(page).to have_content "サブスクリプションが登録されました"
    end
  end
end
