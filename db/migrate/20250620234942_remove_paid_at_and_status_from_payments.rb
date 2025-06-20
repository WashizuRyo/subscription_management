class RemovePaidAtAndStatusFromPayments < ActiveRecord::Migration[8.0]
  def change
    remove_column :payments, :paid_at, :datetime
    remove_column :payments, :status, :integer
  end
end
