class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :method_type
      t.string :provider
      t.string :memo

      t.timestamps
    end
  end
end
