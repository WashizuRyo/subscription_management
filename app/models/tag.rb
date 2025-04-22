class Tag < ApplicationRecord
  has_many :subscription_tags
  has_many :subscriptions, through: :subscription_tags
end
