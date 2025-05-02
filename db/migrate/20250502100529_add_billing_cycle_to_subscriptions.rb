class AddBillingCycleToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :billing_cycle, :string
  end
end
