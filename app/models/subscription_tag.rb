class SubscriptionTag < ApplicationRecord
  belongs_to :subscription
  belongs_to :tag
end
