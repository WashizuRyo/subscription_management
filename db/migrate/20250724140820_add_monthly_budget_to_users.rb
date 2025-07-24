class AddMonthlyBudgetToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :monthly_budget, :decimal
  end
end
