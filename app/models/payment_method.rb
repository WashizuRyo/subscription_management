class PaymentMethod < ApplicationRecord
  has_many :subscriptions
  has_many :payments, dependent: :destroy

  belongs_to :user

  validates :provider, presence: true
  validates :method_type, presence: true

  scope :search_by_provider_or_type, ->(q) { where("provider LIKE :q OR method_type LIKE :q", q: "%#{q}%") }
end
