class Subscription < ApplicationRecord
  belongs_to :user

  validates :subscription_name, presence: true
  validates :plan_name, presence: true
  validates :price, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :billing_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "終了日は開始日より後の日付に設定してください")
    end
  end
end
