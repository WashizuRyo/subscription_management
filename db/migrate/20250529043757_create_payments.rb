class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :billing_date, null: false
      t.datetime :paid_at
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :payments, [ :subscription_id, :billing_date ], unique: true
    add_index :payments, :billing_date
  end
end
