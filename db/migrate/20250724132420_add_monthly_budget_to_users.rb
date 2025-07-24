class AddMonthlyBudgetToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :monthly_budget, :decimal, precision: 8, scale: 2
  end
end
