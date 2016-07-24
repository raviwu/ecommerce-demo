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

ActiveRecord::Schema.define(version: 20160724035210) do

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

  create_table "roles", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
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
