require 'rails_helper'

RSpec.describe "PaymentMethods", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:payment_method) { FactoryBot.create(:payment_method, user: user) }
  let(:other_user_payment_method) { FactoryBot.create(:payment_method, user: other_user) }

  describe "GET index" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root path" do
          get user_payment_methods_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        get root_path
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST create" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          post user_payment_methods_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        post user_payment_methods_path(other_user)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "PATCH update" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          patch user_payment_method_path(other_user, id: other_user_payment_method)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        patch user_payment_method_path(other_user, id: other_user_payment_method)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "DELETE destroy" do
    context "logged in" do
      before do
        login_as user
      end

      context "not authorized" do
        it "redirects to root_path" do
          delete user_payment_method_path(other_user, id: other_user_payment_method)
          expect(response).to redirect_to root_path
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        delete user_payment_method_path(other_user, id: other_user_payment_method)
        expect(response).to redirect_to login_path
      end
    end
  end
end
