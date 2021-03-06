# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160727225557) do

  create_table "classifications", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "attn_name",  null: false
    t.string   "email"
    t.string   "phone"
    t.string   "address"
    t.string   "zipcode"
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "symbol",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventory_units", force: :cascade do |t|
    t.string   "status",       default: "available", null: false
    t.integer  "variant_id",                         null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "line_item_id"
    t.index ["variant_id"], name: "index_inventory_units_on_variant_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string   "invoice_number", null: false
    t.integer  "payment_id",     null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["payment_id"], name: "index_invoices_on_payment_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "order_id",                        null: false
    t.integer  "variant_id",                      null: false
    t.integer  "currency_id",                     null: false
    t.integer  "unit_price",      default: 0,     null: false
    t.integer  "quantity",        default: 0,     null: false
    t.boolean  "lock_inventory",  default: false, null: false
    t.integer  "line_item_total",                 null: false
    t.integer  "promo_total"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["currency_id"], name: "index_line_items_on_currency_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["variant_id"], name: "index_line_items_on_variant_id"
  end

  create_table "line_items_promotions", force: :cascade do |t|
    t.integer "line_item_id",    null: false
    t.integer "promotion_id",    null: false
    t.integer "discount_amount"
    t.index ["line_item_id"], name: "index_line_items_promotions_on_line_item_id"
    t.index ["promotion_id"], name: "index_line_items_promotions_on_promotion_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "order_number",                      null: false
    t.integer  "user_id",                           null: false
    t.text     "billing_contact_info",              null: false
    t.text     "shipping_contact_info",             null: false
    t.integer  "currency_id",                       null: false
    t.integer  "shipment_id"
    t.integer  "line_item_total",       default: 0, null: false
    t.integer  "promo_total",           default: 0, null: false
    t.string   "status",                            null: false
    t.datetime "completed_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["currency_id"], name: "index_orders_on_currency_id"
    t.index ["shipment_id"], name: "index_orders_on_shipment_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "orders_promotions", force: :cascade do |t|
    t.integer "order_id",        null: false
    t.integer "promotion_id",    null: false
    t.integer "discount_amount"
    t.index ["order_id"], name: "index_orders_promotions_on_order_id"
    t.index ["promotion_id"], name: "index_orders_promotions_on_promotion_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string   "payment_number",             null: false
    t.integer  "order_id",                   null: false
    t.integer  "user_id",                    null: false
    t.integer  "currency_id",                null: false
    t.integer  "amount",         default: 0, null: false
    t.string   "status",                     null: false
    t.string   "payment_method",             null: false
    t.datetime "paid_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["currency_id"], name: "index_payments_on_currency_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",              null: false
    t.string   "description"
    t.text     "properties"
    t.datetime "available_on",      null: false
    t.datetime "deleted_at"
    t.integer  "classification_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["classification_id"], name: "index_products_on_classification_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.string   "scope",                       null: false
    t.string   "description",                 null: false
    t.text     "rule",                        null: false
    t.datetime "start_at",                    null: false
    t.datetime "expire_at",                   null: false
    t.boolean  "active",      default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.string   "logistics_number", null: false
    t.integer  "user_id",          null: false
    t.integer  "handle_staff_id",  null: false
    t.string   "shipment_method",  null: false
    t.string   "status",           null: false
    t.datetime "delivered_at"
    t.datetime "arrived_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["user_id"], name: "index_shipments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",           null: false
    t.string   "name",            null: false
    t.string   "password_digest", null: false
    t.integer  "role_id",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "variant_assets", force: :cascade do |t|
    t.string   "description"
    t.integer  "position"
    t.string   "attachment_file_name",    null: false
    t.string   "attachment_content_type", null: false
    t.integer  "attachment_file_size",    null: false
    t.datetime "attachment_updated_at",   null: false
    t.integer  "variant_id",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["variant_id"], name: "index_variant_assets_on_variant_id"
  end

  create_table "variants", force: :cascade do |t|
    t.integer  "currency_id",      null: false
    t.integer  "product_id",       null: false
    t.integer  "price",            null: false
    t.integer  "stock_item_count"
    t.text     "properties"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["currency_id"], name: "index_variants_on_currency_id"
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

end
