require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { FactoryBot.build(:user) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_length_of(:name).is_at_most(50) }
  it { is_expected.to validate_length_of(:email).is_at_most(255) }
  it { is_expected.to validate_presence_of :password }
  it { is_expected.to validate_length_of(:password).is_at_least(6) }
  it { is_expected.to_not validate_length_of(:password).is_at_least(5) }

  it "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      user.email = valid_address
      aggregate_failures do
        expect(user).to be_valid, "#{valid_address.inspect} should be valid"
      end
    end
  end

  it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    aggregate_failures do
      invalid_addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).to_not be_valid, "#{invalid_address.inspect} should be invalid"
      end
    end
  end

  it "email addresses should be unique" do
    duplicate_user = user.dup
    user.save
    expect(duplicate_user).to_not be_valid
  end

  it "email addresses should be saved as lowercase" do
    mixed_case_email = "FoO@example.COM"
    user.email = mixed_case_email
    user.save
    expect(user.email).to eq mixed_case_email.downcase
  end

  it "authenticated? should return false for a user with nil digest" do
    expect(user.authenticated?("")).to be_falsy
  end

  describe "search_subscriptions" do
    it "returns subscriptions that match the search_column" do
      FactoryBot.create(:subscription,
                                       subscription_name: "Netflix",
                                       price: 10000,
                                       plan_name: "standard",
                                       user: user)

      result = user.search_subscriptions(search_column: "subscription_name",
                                         search_value: "Netflix").first

      aggregate_failures do
        expect(result.subscription_name).to eq "Netflix"
        expect(result.price).to eq 10000
        expect(result.plan_name).to eq "standard"
      end
    end

    it "returns subscriptions that sorted by order" do
      FactoryBot.create(:subscription, user: user, price: 10, subscription_name: "Netflix")
      FactoryBot.create(:subscription, user: user, price: 20, subscription_name: "netflix")
      FactoryBot.create(:subscription, user: user, price: 30, subscription_name: "Net")

      result = user.search_subscriptions(search_column: "subscription_name",
                                         search_value: "net",
                                         order_by: [ { "price" => "desc" } ])

      aggregate_failures do
        expect(result.length).to eq 3
        expect(result.first.price).to eq 30
        expect(result.second.price).to eq 20
        expect(result.third.price).to eq 10
      end
    end

    it "returns subscriptions that sorted by orders" do
      FactoryBot.create(:subscription, user: user, price: 10, plan_name: "standard")
      FactoryBot.create(:subscription, user: user, price: 20, plan_name: "standard")
      FactoryBot.create(:subscription, user: user, price: 30, plan_name: "standard")
      first_column = "plan_name"
      first_direction = "asc"
      second_column = "price"
      second_direction = "asc"
      orders = [ { first_column => first_direction }, { second_column => second_direction } ]

      result = user.search_subscriptions(search_column: "plan_name",
                                         search_value: "standard",
                                         order_by: orders)

      aggregate_failures do
        expect(result.length).to eq 3
        expect(result.first.price).to eq 10
        expect(result.second.price).to eq 20
        expect(result.third.price).to eq 30
      end
    end

    it "returns all subscriptions when args not exits" do
      user = FactoryBot.create(:user, :with_subscriptions)
      result = user.search_subscriptions
      expect(result.length).to eq 5
    end

    it "returns Argument Error when search_column is not allowed" do
      expect do
        user.search_subscriptions(search_column: "invalid",
                                  search_value: "Amazon")
      end.to raise_error(ArgumentError, "無効なカラム名です: invalid")
    end

    it "returns subscriptions that exactly match when search_column is 'price'" do
      FactoryBot.create(:subscription, user: user, price: 9000)
      FactoryBot.create(:subscription, user: user, price: 900)
      FactoryBot.create(:subscription, user: user, price: 90)

      result = user.search_subscriptions(search_column: "price",
                                         search_value: 90)

      aggregate_failures do
        expect(result.length).to eq 1
        expect(result.first.price).to eq 90
      end
    end

    it "returns 5 subscriptions when page is 1" do
      user = FactoryBot.create(:user, :with_many_subscriptions)

      result = user.search_subscriptions(page: 1)
      expect(result.length).to eq 5
    end

    it "returns 5 subscriptions when search_column is ''(blank)" do
      user = FactoryBot.create(:user, :with_subscriptions)

      result = user.search_subscriptions(search_column: "")
      expect(result.length).to eq 5
    end
  end
end
