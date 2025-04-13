class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.string :subscriptions_name
      t.string :plan_name
      t.decimal :price, precision: 10, scale: 2
      t.date :start_date
      t.date :end_date
      t.date :billing_date

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
