require 'rails_helper'

RSpec.describe "Subscriptions", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:subscription) { FactoryBot.create(:subscription, user: user) }

  it "user can create subscription" do
    login_as user

    visit new_user_subscription_path(user)

    expect do
      fill_in_subscription_form(1000,
                                "Netflix",
                                "スタンダード",
      )
      click_button "送信する"
    end.to change(Subscription, :count).by(1)

    aggregate_failures do
      expect(page).to have_current_path root_path
      expect(page).to have_content "サブスクリプションが登録されました"
    end
  end

  it "user redirect to root_path when access to other user /uses/:id/subscriptions/new" do
    login_as user

    visit new_user_subscription_path(other_user)

    aggregate_failures do
      expect(page).to have_content "権限がありません"
      expect(page).to have_current_path root_path
    end
  end

  it "user can edit subscription" do
    login_as user

    visit edit_user_subscription_path(user, id: subscription.id)

    fill_in_subscription_form(100, "Spotify")
    click_button "送信する"

    aggregate_failures do
      expect(page).to have_current_path root_path
      expect(subscription.reload.price).to eq 100
      expect(subscription.reload.subscription_name).to eq "Spotify"
    end
  end

  def fill_in_subscription_form(price = 1000,
                                subscription_name = "Netflix",
                                plan_name = "スタンダード",
                                start_date = Time.zone.today,
                                end_date = 1.months.from_now.to_date,
                                billing_date = 1.months.from_now.to_date)
    fill_in "値段", with: price
    fill_in "名前", with: subscription_name
    fill_in "プラン名", with: plan_name
    fill_in "開始日", with: start_date
    fill_in "終了日", with: end_date
    fill_in "請求日", with: billing_date
  end
end
