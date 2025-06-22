class ChangeBillingDayOfMonthToInteger < ActiveRecord::Migration[8.0]
  def change
    change_column :subscriptions, :billing_day_of_month, :integer, using: 'EXTRACT(DAY FROM billing_day_of_month)::integer'
  end
end
