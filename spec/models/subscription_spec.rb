require 'rails_helper'

RSpec.describe Subscription, type: :model do
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
