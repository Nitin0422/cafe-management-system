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

ActiveRecord::Schema[8.1].define(version: 2026_09_08_000015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_categories_on_created_by_id"
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["position"], name: "index_categories_on_position"
    t.index ["updated_by_id"], name: "index_categories_on_updated_by_id"
  end

  create_table "credit_accounts", force: :cascade do |t|
    t.integer "balance_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.bigint "user_id", null: false
    t.index ["created_by_id"], name: "index_credit_accounts_on_created_by_id"
    t.index ["status"], name: "index_credit_accounts_on_status"
    t.index ["updated_by_id"], name: "index_credit_accounts_on_updated_by_id"
    t.index ["user_id"], name: "index_credit_accounts_on_user_id", unique: true
  end

  create_table "ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.decimal "low_stock_threshold", precision: 10, scale: 3, default: "0.0", null: false
    t.string "name", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_ingredients_on_created_by_id"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
    t.index ["updated_by_id"], name: "index_ingredients_on_updated_by_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.text "description"
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.boolean "redeemable", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["available"], name: "index_menu_items_on_available"
    t.index ["category_id", "available"], name: "index_menu_items_on_category_id_and_available"
    t.index ["category_id"], name: "index_menu_items_on_category_id"
    t.index ["created_by_id"], name: "index_menu_items_on_created_by_id"
    t.index ["name"], name: "index_menu_items_on_name", unique: true
    t.index ["updated_by_id"], name: "index_menu_items_on_updated_by_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.bigint "menu_item_id", null: false
    t.bigint "order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.boolean "redeemed", default: false, null: false
    t.integer "subtotal_cents", null: false
    t.integer "unit_price_cents", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_order_items_on_created_by_id"
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id", "menu_item_id"], name: "index_order_items_on_order_id_and_menu_item_id"
    t.index ["updated_by_id"], name: "index_order_items_on_updated_by_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "closed_at"
    t.bigint "closed_by_id"
    t.integer "closure_type"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.bigint "customer_id"
    t.string "order_number", null: false
    t.integer "status", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["closed_by_id"], name: "index_orders_on_closed_by_id"
    t.index ["closure_type"], name: "index_orders_on_closure_type"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["created_by_id"], name: "index_orders_on_created_by_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["updated_by_id"], name: "index_orders_on_updated_by_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.bigint "order_id", null: false
    t.integer "payment_type", null: false
    t.string "reference"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_at"], name: "index_payments_on_created_at"
    t.index ["created_by_id"], name: "index_payments_on_created_by_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["payment_type"], name: "index_payments_on_payment_type"
    t.index ["updated_by_id"], name: "index_payments_on_updated_by_id"
  end

  create_table "points_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "description"
    t.integer "entry_type", null: false
    t.bigint "order_id"
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_points_entries_on_created_at"
    t.index ["created_by_id"], name: "index_points_entries_on_created_by_id"
    t.index ["entry_type"], name: "index_points_entries_on_entry_type"
    t.index ["order_id"], name: "index_points_entries_on_order_id"
    t.index ["updated_by_id"], name: "index_points_entries_on_updated_by_id"
    t.index ["user_id", "created_at"], name: "index_points_entries_on_user_id_and_created_at"
  end

  create_table "recipe_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.bigint "ingredient_id", null: false
    t.bigint "menu_item_id", null: false
    t.decimal "quantity", precision: 10, scale: 3, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_recipe_items_on_created_by_id"
    t.index ["ingredient_id"], name: "index_recipe_items_on_ingredient_id"
    t.index ["menu_item_id", "ingredient_id"], name: "index_recipe_items_on_menu_item_id_and_ingredient_id", unique: true
    t.index ["updated_by_id"], name: "index_recipe_items_on_updated_by_id"
  end

  create_table "rewards_configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.decimal "points_per_rupee", precision: 10, scale: 4, default: "1.0", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_rewards_configs_on_created_by_id"
    t.index ["updated_by_id"], name: "index_rewards_configs_on_updated_by_id"
  end

  create_table "stock_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.integer "entry_type", null: false
    t.bigint "ingredient_id", null: false
    t.text "note"
    t.decimal "quantity", precision: 10, scale: 3, null: false
    t.string "reference"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_at"], name: "index_stock_entries_on_created_at"
    t.index ["created_by_id"], name: "index_stock_entries_on_created_by_id"
    t.index ["entry_type"], name: "index_stock_entries_on_entry_type"
    t.index ["ingredient_id", "created_at"], name: "index_stock_entries_on_ingredient_id_and_created_at"
    t.index ["updated_by_id"], name: "index_stock_entries_on_updated_by_id"
  end

  create_table "tab_payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.bigint "credit_account_id", null: false
    t.text "note"
    t.integer "payment_type", null: false
    t.string "reference"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_at"], name: "index_tab_payments_on_created_at"
    t.index ["created_by_id"], name: "index_tab_payments_on_created_by_id"
    t.index ["credit_account_id"], name: "index_tab_payments_on_credit_account_id"
    t.index ["updated_by_id"], name: "index_tab_payments_on_updated_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["active"], name: "index_users_on_active"
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true, where: "(phone IS NOT NULL)"
    t.index ["role"], name: "index_users_on_role"
    t.index ["updated_by_id"], name: "index_users_on_updated_by_id"
  end

  add_foreign_key "categories", "users", column: "created_by_id"
  add_foreign_key "categories", "users", column: "updated_by_id"
  add_foreign_key "credit_accounts", "users"
  add_foreign_key "credit_accounts", "users", column: "created_by_id"
  add_foreign_key "credit_accounts", "users", column: "updated_by_id"
  add_foreign_key "ingredients", "users", column: "created_by_id"
  add_foreign_key "ingredients", "users", column: "updated_by_id"
  add_foreign_key "menu_items", "categories"
  add_foreign_key "menu_items", "users", column: "created_by_id"
  add_foreign_key "menu_items", "users", column: "updated_by_id"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "users", column: "created_by_id"
  add_foreign_key "order_items", "users", column: "updated_by_id"
  add_foreign_key "orders", "users", column: "closed_by_id"
  add_foreign_key "orders", "users", column: "created_by_id"
  add_foreign_key "orders", "users", column: "customer_id"
  add_foreign_key "orders", "users", column: "updated_by_id"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "users", column: "created_by_id"
  add_foreign_key "payments", "users", column: "updated_by_id"
  add_foreign_key "points_entries", "orders"
  add_foreign_key "points_entries", "users"
  add_foreign_key "points_entries", "users", column: "created_by_id"
  add_foreign_key "points_entries", "users", column: "updated_by_id"
  add_foreign_key "recipe_items", "ingredients"
  add_foreign_key "recipe_items", "menu_items"
  add_foreign_key "recipe_items", "users", column: "created_by_id"
  add_foreign_key "recipe_items", "users", column: "updated_by_id"
  add_foreign_key "rewards_configs", "users", column: "created_by_id"
  add_foreign_key "rewards_configs", "users", column: "updated_by_id"
  add_foreign_key "stock_entries", "ingredients"
  add_foreign_key "stock_entries", "users", column: "created_by_id"
  add_foreign_key "stock_entries", "users", column: "updated_by_id"
  add_foreign_key "tab_payments", "credit_accounts"
  add_foreign_key "tab_payments", "users", column: "created_by_id"
  add_foreign_key "tab_payments", "users", column: "updated_by_id"
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "updated_by_id"
end
