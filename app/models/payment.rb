class Payment < ApplicationRecord
  belongs_to :subscription
  belongs_to :payment_method

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :billing_date, presence: true
  # validates :status, presence: true

  scope :total_amount, -> { sum(:amount) }
end
