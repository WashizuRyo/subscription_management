class PaymentMethod < ApplicationRecord
  has_many :subscriptions
  has_many :payments, dependent: :destroy

  belongs_to :user

  validates :provider, presence: true
  validates :method_type, presence: true
end
