class AddPlanToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :plan, :string
  end
end
