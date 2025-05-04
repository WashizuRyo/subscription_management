require 'rails_helper'

RSpec.describe "Navigation", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    login_as user
  end

  describe "GET /dashboard" do
    it "sets dashboard tab as active" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('<a class="nav-link active" href="/')
      expect(response.body).to include('<i class="bi bi-house"></i> ホーム')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/subscriptions">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/tags">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/payment_methods">')
    end
  end

  describe "GET /subscriptions" do
    it "sets subscriptions tab as active" do
      get user_subscriptions_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/subscriptions">')
      expect(response.body).to include('<i class="bi bi-list-task"></i> サブスクリプション')
      expect(response.body).not_to include('<a class="nav-link active" href="/">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/tags">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/payment_methods">')
    end
  end

  describe "GET /tags" do
    it "sets tags tab as active" do
      get user_tags_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/tags">')
      expect(response.body).to include('<i class="bi bi-tags"></i> タグ')
      expect(response.body).not_to include('<a class="nav-link active" href="/">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/subscriptions">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/payment_methods">')
    end
  end

  describe "GET /payment_methods" do
    it "sets payment methods tab as active" do
      get user_payment_methods_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/payment_methods">')
      expect(response.body).to include('<i class="bi bi-credit-card"></i> 支払い方法')
      expect(response.body).not_to include('<a class="nav-link active" href="/">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/subscriptions">')
      expect(response.body).not_to include('<a class="nav-link active" href="/users/' + user.id.to_s + '/tags">')
    end
  end
end
