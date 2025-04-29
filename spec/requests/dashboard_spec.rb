require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /" do
    let(:user) { FactoryBot.create(:user) }
    context "logged in" do
      it "returns http success" do
        login_as user
        get root_path
        expect(response).to have_http_status(:success)
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
