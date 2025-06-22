require "rails_helper"

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
            expect(response.body).to include(subscription.name)
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

      context "when user checked create payment history" do
        let(:payment_method) { FactoryBot.create(:payment_method, user:) }
        let(:params) do
          {
            subscription: {
              name: "New Subscription",
              plan: "Basic",
              price: 1000,
              start_date: Date.today,
              billing_day_of_month: 1,
              create_initial_payment: "1",
              payment_method_id: payment_method.id
            }
          }
        end

        subject { post user_subscriptions_path(user), params: }

        it "should create subscriptions and payment" do
          expect {
            subject
          }.to change { user.subscriptions.count }.by(1)
            .and change { Payment.count }.by(1)

          payment = user.subscriptions.last.payments.first
          subscription = user.subscriptions.last
          expect(payment.billing_date).to eq subscription.start_date
          expect(payment.payment_method).to eq subscription.payments.first.payment_method
          expect(payment.amount).to eq subscription.price
          expect(payment.plan).to eq subscription.plan
          expect(payment.billing_cycle).to eq subscription.billing_cycle
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

      context "with valid params" do
        let(:subscription) { user.subscriptions.first }
        let(:tag) { FactoryBot.create(:tag) }

        before do
          subscription.tags << tag
        end

        it "removes all tags when no tags are selected" do
          # タグが選択されなかったら, クエリにtag_idsが含まれない
          patch user_subscription_path(user, subscription), params: {
            subscription: {
              name: subscription.name
            }
          }

          expect(response).to redirect_to root_path
          follow_redirect!
          expect(response.body).to include "サブスクリプションを更新しました"
          expect(subscription.reload.tags).to be_empty
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
