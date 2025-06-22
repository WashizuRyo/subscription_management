class AddBillingCycleToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :billing_cycle, :integer
  end
end
