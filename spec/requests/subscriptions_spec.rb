require 'rails_helper'

RSpec.describe "Subscriptions", type: :request do
  let(:user) { FactoryBot.create(:user, :with_subscriptions) }

  describe "GET /user_subscriptions_path" do
    context "logged in" do
      before do
        login_as user
      end

      it "returns subscriptions" do
        get user_subscriptions_path(user)

        aggregate_failures do
          expect(response).to have_http_status :ok
          user.subscriptions.each do |subscription|
            expect(response.body).to include(subscription.subscription_name)
          end
        end
      end

      it "returns error flash when invalid column" do
        get user_subscriptions_path(user, { first_column: "invalid_column", first_direction: "desc" })

        aggregate_failures do
          expect(response.body).to include("無効なカラム名です: invalid_column")
          user.subscriptions.each do |subscription|
            expect(response.body).to include(subscription.subscription_name)
          end
        end
      end
    end

    it "redirects to login_path when not logged in" do
      get user_subscriptions_path(user)
      expect(response).to redirect_to login_path
    end
  end
end
