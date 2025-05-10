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
      FactoryBot.create(:subscription, user: user, price: 100)
      FactoryBot.create(:subscription, user: user, price: 200)
      FactoryBot.create(:subscription, user: user, price: 300)
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              first_column: "price",
                              first_direction: "asc")
      subscriptions = form.search_subscriptions
      expect(subscriptions.map(&:price)).to eq([ 100, 200, 300 ])
    end

    it "returns subscriptions when price exactly matches search value (exact match)" do
      FactoryBot.create(:subscription, user: user, price: 9000)
      FactoryBot.create(:subscription, user: user, price: 900)
      FactoryBot.create(:subscription, user: user, price: 90)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "price",
                              search_value: 90,
                              search_date_start: 90,
                              search_date_value_pattern: "exact")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 1
      expect(subscriptions.first.price).to eq 90
    end

    it "returns subscriptions when name contains search term (partial match)" do
      FactoryBot.create(:subscription, user: user, name: "Netflix Premium")
      FactoryBot.create(:subscription, user: user, name: "Netflix Basic")
      FactoryBot.create(:subscription, user: user, name: "Amazon Prime")
      FactoryBot.create(:subscription, user: user, name: "Disney Plus")

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "name",
                              search_value: "netflix",
                              search_value_pattern: "partial")
      subscriptions = form.search_subscriptions

      expect(subscriptions.map(&:name)).to match_array([ "Netflix Premium", "Netflix Basic" ])
    end

    it "returns subscriptions when name ends with search term (end_with match)" do
      FactoryBot.create(:subscription, user: user, name: "Netflix Premium")
      FactoryBot.create(:subscription, user: user, name: "Netflix Basic")
      FactoryBot.create(:subscription, user: user, name: "Amazon Prime")
      FactoryBot.create(:subscription, user: user, name: "Disney Plus")

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "name",
                              search_value: "Premium",
                              search_value_pattern: "end_with")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 1
      expect(subscriptions.first.name).to eq "Netflix Premium"
    end

    it "returns subscriptions when name starts with search term (start_with match)" do
      FactoryBot.create(:subscription, user: user, name: "Netflix Premium")
      FactoryBot.create(:subscription, user: user, name: "Netflix Basic")
      FactoryBot.create(:subscription, user: user, name: "Amazon Prime")
      FactoryBot.create(:subscription, user: user, name: "Disney Plus")

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "name",
                              search_value: "Netflix",
                              search_value_pattern: "start_with")
      subscriptions = form.search_subscriptions

      expect(subscriptions.map(&:name)).to match_array([ "Netflix Premium", "Netflix Basic" ])
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

      expect(subscriptions.map(&:name)).to eq([ "Net", "netflix", "Netflix" ])
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

      expect(subscriptions.map(&:price)).to eq([ 10, 20, 30 ])
    end

    it "returns subscriptions when start_date exactly matches search date (exact match)" do
      date1 = Date.new(2023, 1, 15)
      date2 = Date.new(2023, 2, 1)
      date3 = Date.new(2023, 3, 10)

      FactoryBot.create(:subscription, user: user, start_date: date1)
      FactoryBot.create(:subscription, user: user, start_date: date2)
      FactoryBot.create(:subscription, user: user, start_date: date3)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "start_date",
                              search_value: date2.to_s,
                              search_date_start: date2,
                              search_date_value_pattern: "exact")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 1
      expect(subscriptions.first.start_date).to eq date2
    end

    it "returns subscriptions when start_date is before search date (before match)" do
      date1 = Date.new(2023, 1, 15)
      date2 = Date.new(2023, 2, 1)
      date3 = Date.new(2023, 3, 10)

      FactoryBot.create(:subscription, user: user, start_date: date1)
      FactoryBot.create(:subscription, user: user, start_date: date2)
      FactoryBot.create(:subscription, user: user, start_date: date3)

      search_date = Date.new(2023, 2, 15)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "start_date",
                              search_value: search_date.to_s,
                              search_date_start: search_date,
                              search_date_value_pattern: "before")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 2
      expect(subscriptions.map(&:start_date)).to match_array([ date1, date2 ])
    end

    it "returns subscriptions when start_date is after search date (after match)" do
      date1 = Date.new(2023, 1, 15)
      date2 = Date.new(2023, 2, 1)
      date3 = Date.new(2023, 3, 10)

      FactoryBot.create(:subscription, user: user, start_date: date1)
      FactoryBot.create(:subscription, user: user, start_date: date2)
      FactoryBot.create(:subscription, user: user, start_date: date3)

      search_date = Date.new(2023, 2, 15)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "start_date",
                              search_value: search_date.to_s,
                              search_date_start: search_date,
                              search_date_value_pattern: "after")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 1
      expect(subscriptions.first.start_date).to eq date3
    end

    it "returns subscriptions when start_date is between search dates (between match)" do
      date1 = Date.new(2023, 1, 15)
      date2 = Date.new(2023, 2, 1)
      date3 = Date.new(2023, 3, 10)
      date4 = Date.new(2023, 4, 5)

      FactoryBot.create(:subscription, user: user, start_date: date1)
      FactoryBot.create(:subscription, user: user, start_date: date2)
      FactoryBot.create(:subscription, user: user, start_date: date3)
      FactoryBot.create(:subscription, user: user, start_date: date4)

      start_date = Date.new(2023, 1, 20)
      end_date = Date.new(2023, 3, 15)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "start_date",
                              search_value: start_date,
                              search_date_start: start_date,
                              search_date_end: end_date,
                              search_date_value_pattern: "between")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 2
      expect(subscriptions.map(&:start_date)).to match_array([ date2, date3 ])
    end
  end
end
