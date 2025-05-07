require 'rails_helper'

RSpec.describe SubscriptionTag, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:subscription) }
    it { is_expected.to belong_to(:tag) }
  end
end
