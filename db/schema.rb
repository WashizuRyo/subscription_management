# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_30_070256) do
  create_table "payment_methods", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "method_type"
    t.string "provider"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "subscription_tags", force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscription_tags_on_subscription_id"
    t.index ["tag_id"], name: "index_subscription_tags_on_tag_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "subscription_name"
    t.string "plan_name"
    t.decimal "price", precision: 10, scale: 2
    t.date "start_date"
    t.date "end_date"
    t.date "billing_date"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.integer "status", default: 0, null: false
    t.integer "payment_method_id"
    t.index ["payment_method_id"], name: "index_subscriptions_on_payment_method_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "payment_methods", "users"
  add_foreign_key "subscription_tags", "subscriptions"
  add_foreign_key "subscription_tags", "tags"
  add_foreign_key "subscriptions", "payment_methods"
  add_foreign_key "subscriptions", "users"
end
