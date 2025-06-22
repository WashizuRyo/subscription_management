class RenameBillingDateToBillingDayOfMonthOnSubscriptions < ActiveRecord::Migration[8.0]
  def change
    rename_column :subscriptions, :billing_date, :billing_day_of_month
  end
end
