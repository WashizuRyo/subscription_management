class RenameSubscriptionsNameToSubscriptionName < ActiveRecord::Migration[8.0]
  def change
    rename_column :subscriptions, :subscriptions_name, :subscription_name
  end
end
