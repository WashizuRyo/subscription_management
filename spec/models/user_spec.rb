require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(name: "Example user", email: "user@example.com")
  end

  it "is valid with valid attributes" do
    expect(@user).to be_valid
  end

  it "is invalid without name" do
    @user.name = nil
    expect(@user).to_not be_valid
  end

  it "is invalid without email" do
    @user.email = nil
    expect(@user).to_not be_valid
  end

  it "is invalid with name too long" do
      @user.name = "a" * 51
      expect(@user).to_not be_valid
  end

  it "is invalid with email too long" do
    @user.email = "a" * 244 + "@example.com"
    expect(@user).to_not be_valid
  end
end
