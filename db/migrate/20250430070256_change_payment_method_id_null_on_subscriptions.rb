class ChangePaymentMethodIdNullOnSubscriptions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subscriptions, :payment_method_id, true
  end
end
