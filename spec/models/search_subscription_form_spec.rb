require 'rails_helper'

RSpec.describe SearchSubscriptionForm, type: :model do
  describe "validations" do
    let(:user) { FactoryBot.create(:user) }

    it "is invalid when first_column is not included in ALLOWED_COLUMNS" do
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              first_column: "invalid")
      expect(form).to_not be_valid
      expect(form.errors[:first_column]).to include "無効なカラム名です"
      expect(form.errors.count).to eq 1
    end

    it "is invalid when second_column is not included in ALLOWED_COLUMNS" do
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              second_column: "invalid")
      expect(form).to_not be_valid
      expect(form.errors[:second_column]).to include "無効なカラム名です"
      expect(form.errors.count).to eq 1
    end

    it "is invalid when search_column is not included in ALLOWED_COLUMNS" do
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "invalid")
      expect(form).to_not be_valid
      expect(form.errors[:search_column]).to include "無効なカラム名です"
      expect(form.errors.count).to eq 1
    end

    it "is invalid when first_direction is not included in ALLOWED_DIRECTIONS" do
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              first_direction: "invalid")
      expect(form).to_not be_valid
      expect(form.errors[:first_direction]).to include "無効な並び順です"
      expect(form.errors.count).to eq 1
    end

    it "is invalid when second_direction is not included in ALLOWED_DIRECTIONS" do
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              second_direction: "invalid")
      expect(form).to_not be_valid
      expect(form.errors[:second_direction]).to include "無効な並び順です"
      expect(form.errors.count).to eq 1
    end
  end

  describe "search_subscriptions" do
    let(:user) { FactoryBot.create(:user) }

    it "returns subscriptions without filtering when search params are blank" do
      user = FactoryBot.create(:user, :with_subscriptions)
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "",
                              search_value: "")
      expect(form.search_subscriptions.count).to eq 5
    end

    it "returns subscriptions without filtering when only sorting params are present" do
      sub1 = FactoryBot.create(:subscription, user: user, price: 100)
      sub2 = FactoryBot.create(:subscription, user: user, price: 200)
      sub3 = FactoryBot.create(:subscription, user: user, price: 300)
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              first_column: "price",
                              first_direction: "asc")
      subscriptions = form.search_subscriptions
      expect(subscriptions.count).to eq 3
      expect(subscriptions[0]).to eq sub1
      expect(subscriptions[1]).to eq sub2
      expect(subscriptions[2]).to eq sub3
    end

    it "returns subscriptions that exactly match when search_column is 'price'" do
      FactoryBot.create(:subscription, user: user, price: 9000)
      FactoryBot.create(:subscription, user: user, price: 900)
      FactoryBot.create(:subscription, user: user, price: 90)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "price",
                              search_value: 90)
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 1
      expect(subscriptions.first.price).to eq 90
    end

    it "returns subscriptions that match the search_column / search_value" do
      FactoryBot.create(:subscription,
                        name: "Netflix",
                        price: 10000,
                        plan_name: "standard",
                        user: user)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "name",
                              search_value: "Netflix")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 1
      expect(subscriptions.first.name).to eq "Netflix"
      expect(subscriptions.first.price).to eq 10000
    end

    it "returns subscriptions that sorted by order" do
      FactoryBot.create(:subscription, user: user, price: 10, name: "Netflix")
      FactoryBot.create(:subscription, user: user, price: 20, name: "netflix")
      FactoryBot.create(:subscription, user: user, price: 30, name: "Net")

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "name",
                              search_value: "net",
                              first_column: "price",
                              first_direction: "desc")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 3
      expect(subscriptions.first.price).to eq 30
      expect(subscriptions.second.price).to eq 20
      expect(subscriptions.third.price).to eq 10
    end

    it "returns subscriptions that sorted by orders" do
      FactoryBot.create(:subscription, user: user, price: 10, plan_name: "standard")
      FactoryBot.create(:subscription, user: user, price: 20, plan_name: "standard")
      FactoryBot.create(:subscription, user: user, price: 30, plan_name: "standard")

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "plan_name",
                              search_value: "standard",
                              first_column: "plan_name",
                              first_direction: "asc",
                              second_column: "price",
                              second_direction: "asc")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 3
      expect(subscriptions.first.price).to eq 10
      expect(subscriptions.second.price).to eq 20
      expect(subscriptions.third.price).to eq 30
    end
  end
end
