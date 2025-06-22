class RenamePlanNameToPlanOnSubscriptions < ActiveRecord::Migration[8.0]
  def change
    rename_column :subscriptions, :plan_name, :plan
  end
end
