require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:subscription_tags).dependent(:destroy) }
    it { is_expected.to have_many(:subscriptions).through(:subscription_tags) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
