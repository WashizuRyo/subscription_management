require 'rails_helper'

RSpec.describe "Subscriptions", type: :request do
  let(:user) { FactoryBot.create(:user, :with_subscriptions) }
  let(:other_user) { FactoryBot.create(:user, :with_subscriptions) }

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

      it "returns error message when first_colum is invalid" do
        get user_subscriptions_path(user, { q: { first_column: "invalid_column", first_direction: "desc" } })

        expect(response.body).to include("無効なカラム名です")
      end

      context "not authorized" do
        it "redirects to root_path" do
          get user_subscriptions_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        get user_subscriptions_path(user)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET new action" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          get user_subscriptions_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        get user_subscriptions_path(user)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST create action" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          post user_subscriptions_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        post user_subscriptions_path(user)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET edit action" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          get edit_user_subscription_path(other_user, id: 1)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        get edit_user_subscription_path(other_user.id, id: 1)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST update action" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          post user_subscriptions_path(other_user, id: 1)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        post user_subscriptions_path(1, id: 1)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "DELETE destroy action" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          get user_subscriptions_path(other_user, id: 1)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        post user_subscriptions_path(1, id: 1)
        expect(response).to redirect_to login_path
      end
    end
  end
end
