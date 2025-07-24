require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  describe "GET /users/:id/edit" do
    context "logged in" do
      before { login_as(user) }

      it "returns http success for own edit page" do
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
      end

      it "displays monthly budget field in edit form" do
        get edit_user_path(user)
        expect(response.body).to include("月額予算")
        expect(response.body).to include("monthly_budget")
      end

      context "not authorized" do
        it "redirects to root path when trying to edit other user" do
          get edit_user_path(other_user)
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        get edit_user_path(user)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "PATCH /users/:id" do
    context "logged in" do
      before { login_as(user) }

      context "with valid monthly budget" do
        let(:valid_params) do
          {
            user: {
              name: user.name,
              email: user.email,
              monthly_budget: 15000,
              password: "",
              password_confirmation: ""
            }
          }
        end

        it "updates monthly budget successfully" do
          patch user_path(user), params: valid_params
          expect(response).to redirect_to(user_path(user))
          expect(flash[:success]).to eq("設定を更新しました")
          
          user.reload
          expect(user.monthly_budget).to eq(15000)
        end
      end

      context "with zero monthly budget" do
        let(:zero_budget_params) do
          {
            user: {
              name: user.name,
              email: user.email,
              monthly_budget: 0,
              password: "",
              password_confirmation: ""
            }
          }
        end

        it "allows zero budget" do
          patch user_path(user), params: zero_budget_params
          expect(response).to redirect_to(user_path(user))
          
          user.reload
          expect(user.monthly_budget).to eq(0)
        end
      end

      context "with invalid negative budget" do
        let(:invalid_params) do
          {
            user: {
              name: user.name,
              email: user.email,
              monthly_budget: -1000
            }
          }
        end

        it "renders edit template with validation errors" do
          patch user_path(user), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "not authorized" do
        it "redirects to root path when trying to update other user" do
          patch user_path(other_user), params: { user: { monthly_budget: 10000 } }
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        patch user_path(user), params: { user: { monthly_budget: 10000 } }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end