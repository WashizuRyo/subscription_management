class Subscription < ApplicationRecord
  enum :status, { active: 0, canceled: 1, expired: 2, trial: 3 }

  belongs_to :user
  belongs_to :payment_method, optional: true
  has_many :subscription_tags, dependent: :destroy
  has_many :tags, through: :subscription_tags
  has_many :payments, dependent: :destroy

  validates :name, presence: true
  validates :plan, presence: true
  validates :price, presence: true
  validates :start_date, presence: true
  # validates :end_date, presence: true
  validates :billing_day_of_month, presence: true
  # validate :end_date_after_start_date

  scope :billing_in_this_month, ->(user) {
    where(user_id: user).where("billing_day_of_month BETWEEN :start_date AND :end_date",
      start_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month)
  }
  scope :next_billing_soon, ->(user) {
    where("billing_day_of_month > ? AND user_id = ?", Date.today, user)
      .order(billing_day_of_month: :asc)
      .includes(:tags)
      .limit(10)
  }
  scope :latest, ->(user) {
    where(user_id: user)
      .order(created_at: :desc)
      .limit(5)
      .includes(:tags, :payment_method)
  }

  def self.this_month_total_billing(user)
    billing_in_this_month(user).sum(:price)
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "終了日は開始日より後の日付に設定してください")
    end
  end
end
