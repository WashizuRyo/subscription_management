class AddBillingDateToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :billing_date, :date
  end
end
