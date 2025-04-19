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
        expect(Subscription.allowed_sort_orders(valid_orders)).to eq valid_orders
      end
    end

    context "when args is invalid" do
      it "returns Argument Error" do
        invalid_order = [ { "invalid_column" => "asc" } ]
        expect do
          Subscription.allowed_sort_orders(invalid_order)
        end.to raise_error(ArgumentError, "無効なカラム名です: invalid_column")
      end

      it "returns Argument Error" do
        invalid_order = [ { "subscription_name" => "invalid_direction" } ]
        expect do
          Subscription.allowed_sort_orders(invalid_order)
        end.to raise_error(ArgumentError, "無効なソート方向です: invalid_direction")
      end
    end
  end
end
