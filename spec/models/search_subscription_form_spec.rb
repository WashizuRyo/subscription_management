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

    it "is invalid when filter_column is not included in ALLOWED_COLUMNS" do
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              filter_column: "invalid")
      expect(form).to_not be_valid
      expect(form.errors[:filter_column]).to include "無効なカラム名です"
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
                              filter_column: "",
                              text_filter_value: "")
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
                              filter_column: "price",
                              date_filter_start: 90,
                              date_filter_pattern: "exact")
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
                              filter_column: "name",
                              text_filter_value: "netflix",
                              text_filter_pattern: "partial")
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
                              filter_column: "name",
                              text_filter_value: "Premium",
                              text_filter_pattern: "end_with")
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
                              filter_column: "name",
                              text_filter_value: "Netflix",
                              text_filter_pattern: "start_with")
      subscriptions = form.search_subscriptions

      expect(subscriptions.map(&:name)).to match_array([ "Netflix Premium", "Netflix Basic" ])
    end

    it "returns subscriptions that match the search_column / search_value" do
      FactoryBot.create(:subscription,
                        name: "Netflix",
                        price: 10000,
                        plan: "standard",
                        user: user)

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              filter_column: "name",
                              text_filter_value: "Netflix")
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
                              filter_column: "name",
                              text_filter_value: "net",
                              first_column: "price",
                              first_direction: "desc")
      subscriptions = form.search_subscriptions

      expect(subscriptions.map(&:name)).to eq([ "Net", "netflix", "Netflix" ])
    end

    it "returns subscriptions that sorted by orders" do
      FactoryBot.create(:subscription, user: user, price: 10, plan: "standard")
      FactoryBot.create(:subscription, user: user, price: 20, plan: "standard")
      FactoryBot.create(:subscription, user: user, price: 30, plan: "standard")

      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              filter_column: "plan",
                              text_filter_value: "standard",
                              first_column: "plan",
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
                              filter_column: "start_date",
                              date_filter_start: date2,
                              date_filter_pattern: "exact")
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
                              filter_column: "start_date",
                              date_filter_start: search_date,
                              date_filter_pattern: "before")
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
                              filter_column: "start_date",
                              date_filter_start: search_date,
                              date_filter_pattern: "after")
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
                              filter_column: "start_date",
                              date_filter_start: start_date,
                              date_filter_end: end_date,
                              date_filter_pattern: "between")
      subscriptions = form.search_subscriptions

      expect(subscriptions.length).to eq 2
      expect(subscriptions.map(&:start_date)).to match_array([ date2, date3 ])
    end
  end
end
