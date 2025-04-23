class Subscription < ApplicationRecord
  belongs_to :user
  has_many :subscription_tags
  has_many :tags, through: :subscription_tags

  validates :subscription_name, presence: true
  validates :plan_name, presence: true
  validates :price, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :billing_date, presence: true
  validate :end_date_after_start_date

  ALLOWED_COLUMNS = %w[subscription_name plan_name price start_date end_date billing_date]
  ALLOWED_DIRECTIONS = %w[asc desc]

  def self.allowed_sort_orders(orders)
    valid_orders = []

    orders.each do |order|
      column, direction = order.first

      unless ALLOWED_COLUMNS.include?(column)
        raise ArgumentError, "無効なカラム名です: #{column}"
      end

      unless ALLOWED_DIRECTIONS.include?(direction)
        raise ArgumentError, "無効なソート方向です: #{direction}"
      end

      valid_orders << { column => direction }
    end

    valid_orders
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "終了日は開始日より後の日付に設定してください")
    end
  end
end
