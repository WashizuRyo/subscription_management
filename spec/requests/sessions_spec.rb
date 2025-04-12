require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { FactoryBot.create(:user) }
  it "login with remembering" do
    post "/login", params: { session: { email: user.email,
                                        password: user.password,
                                        remember_me: "1" } }
    expect(cookies[:remember_token]).to_not be_nil
  end

  it "login without remembering" do
    post "/login", params: { session: { email: user.email,
                                        password: user.password,
                                        remember_me: "0" } }
    expect(cookies[:remember_token]).to be_nil
  end
end
