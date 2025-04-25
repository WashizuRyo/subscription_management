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
    it "returns subscriptions without filtering when search params are blank" do
      user = FactoryBot.create(:user, :with_subscriptions)
      form = FactoryBot.build(:search_subscription_form,
                              current_user: user,
                              search_column: "",
                              search_value: "")
      expect(form.search_subscriptions.count).to eq 5
    end

    it "returns subscriptions without filtering when only sorting params are present" do
      user = FactoryBot.create(:user)
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
  end
end
