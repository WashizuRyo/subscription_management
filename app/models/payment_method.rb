class PaymentMethod < ApplicationRecord
  has_many :subscriptions
  belongs_to :user
end
