class PaymentMethod < ApplicationRecord
  has_many :subscriptions
  belongs_to :user

  validates :provider, presence: true
  validates :method_type, presence: true
end
