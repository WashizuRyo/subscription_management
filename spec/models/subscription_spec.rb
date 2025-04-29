require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe "validations" do
    let(:user) { FactoryBot.build(:user) }

    it { is_expected.to validate_presence_of :subscription_name }
    it { is_expected.to validate_presence_of :plan_name }
    it { is_expected.to validate_presence_of :price }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :end_date }
    it { is_expected.to validate_presence_of :billing_date }
    it "is valid when end_date is after start_date" do
      subscription = FactoryBot.build(:subscription,
                                      user: user,
                                      start_date: Date.today,
                                      end_date: Date.today + 1)
      expect(subscription).to be_valid
    end

    it "is invalid when end_date == start_date" do
      subscription = FactoryBot.build(:subscription,
                                      user: user,
                                      start_date: Date.today,
                                      end_date: Date.today)
      expect(subscription).to_not be_valid
    end

    it "is invalid when end_date is before start_date" do
      subscription = FactoryBot.build(:subscription,
                                       user: user,
                                       start_date: Date.today,
                                      end_date: Date.today - 1)
      expect(subscription).to_not be_valid
    end
  end

  describe "allowed_sort_orders" do
    context "when args is valid" do
      it "returns arguments" do
        valid_orders = [ { "price" => "asc" }, { "subscription_name" => "desc"  } ]
        expect(Subscription.validate_orders(valid_orders)).to eq valid_orders
      end
    end

    context "when args is invalid" do
      it "returns Argument Error" do
        invalid_order = [ { "invalid_column" => "asc" } ]
        expect do
          Subscription.validate_orders(invalid_order)
        end.to raise_error(ArgumentError, "無効なカラム名です: invalid_column")
      end

      it "returns Argument Error" do
        invalid_order = [ { "subscription_name" => "invalid_direction" } ]
        expect do
          Subscription.validate_orders(invalid_order)
        end.to raise_error(ArgumentError, "無効なソート方向です: invalid_direction")
      end
    end
  end

  describe "this_month_total_billing" do
    let(:user) { FactoryBot.create(:user) }

    it "returns the total price for billings with billing_date in April" do
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 3, 3))
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 4, 3), price: 2000)
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 4, 3), price: 1980)
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 5, 3))

      travel_to Date.new(2025, 4, 1) do
        result = Subscription.this_month_total_billing(user)
        expect(result).to eq 3980
      end
    end

    it "returns 0 when there are no billings with billing_date in April" do
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 1, 3))
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 2, 3))
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 3, 3))

      travel_to Date.new(2025, 4, 1) do
        result = Subscription.this_month_total_billing(user)
        expect(result).to eq 0
      end
    end

    it "does not mix billing dates from same month in different years" do
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 1, 3), price: 100)
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2026, 1, 3), price: 200)
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2027, 1, 3), price: 300)

      travel_to Date.new(2025, 1, 1) do
        result = Subscription.this_month_total_billing(user)
        expect(result).to eq 100
      end
    end
  end

  describe "next_billing_soon" do
    let(:user) { FactoryBot.create(:user) }

    it "returns subscriptions sorted by billing date close to today" do
      today = Date.new(2025, 1, 1)
      sub1 = FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 2, 3), price: 100)
      sub2 = FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 3, 3), price: 200)
      sub3 = FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 4, 3), price: 300)

      travel_to today do
        result = Subscription.next_billing_soon(user)
        expect(result.count).to eq 3
        expect(result.first).to eq sub1
        expect(result.second).to eq sub2
        expect(result.third).to eq sub3
      end
    end

    it "does not include subscriptions with billing date equal to today" do
      today = Date.new(2025, 1, 1)
      FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 1, 1), price: 100)
      sub1 = FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 3, 3), price: 200)
      sub2 = FactoryBot.create(:subscription, user: user, billing_date: Date.new(2025, 4, 3), price: 300)

      travel_to today do
        result = Subscription.next_billing_soon(user)
        expect(result.count).to eq 2
        expect(result.first).to eq sub1
        expect(result.second).to eq sub2
      end
    end
  end
end
