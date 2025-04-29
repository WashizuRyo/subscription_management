require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /" do
    let(:user) { FactoryBot.create(:user) }

    context "logged in" do
      before do
        login_as user
      end

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "responds to subscriptions that include tags" do
        sub = FactoryBot.create(:subscription, user: user, subscription_name: "test_sub")
        tag = FactoryBot.create(:tag, name: "test_tag")
        FactoryBot.create(:subscription_tag, subscription: sub, tag: tag)

        get root_path
        expect(response.body).to include "test_sub"
        expect(response.body).to include "test_tag"
      end
    end

    context "not logged in" do
      it "redirects to login_path" do
        get root_path
        expect(response).to redirect_to login_path
      end
    end
  end
end
