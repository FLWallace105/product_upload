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

ActiveRecord::Schema.define(version: 2019_07_18_203620) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ellie_products", force: :cascade do |t|
    t.string "shopify_product_id"
    t.string "title"
    t.text "body_html"
    t.boolean "updated", default: false
    t.string "handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ellie_staging_products", force: :cascade do |t|
    t.string "shopify_product_id"
    t.string "title"
    t.text "body_html"
    t.boolean "updated", default: false
    t.string "handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "main_products", force: :cascade do |t|
    t.string "handle"
    t.string "title"
    t.text "body_html"
    t.string "vendor"
    t.string "product_type"
    t.string "tags"
    t.boolean "published"
    t.string "option1_name"
    t.string "option2_name"
    t.string "option3_name"
    t.text "image_src"
    t.text "image_alt_text"
    t.boolean "gift_card"
    t.string "collection"
    t.string "color_id"
    t.boolean "uploaded", default: false
    t.datetime "uploaded_at"
    t.bigint "product_id"
  end

  create_table "marika_products", force: :cascade do |t|
    t.string "shopify_product_id"
    t.string "title"
    t.text "body_html"
    t.boolean "updated", default: false
    t.string "handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "handle"
    t.string "title"
    t.text "body_html"
    t.string "vendor"
    t.string "product_type"
    t.string "tags"
    t.boolean "published"
    t.string "option1_name"
    t.string "option1_value"
    t.string "option2_name"
    t.string "option2_value"
    t.string "option3_name"
    t.string "option3_value"
    t.bigint "variant_sku"
    t.bigint "variant_gram"
    t.string "variant_inventory_tracker"
    t.bigint "inventory_qty"
    t.string "variant_inventory_policy"
    t.string "variant_fulfillment_service"
    t.decimal "variant_price", precision: 9, scale: 2
    t.decimal "variant_compare_at_price", precision: 9, scale: 2
    t.boolean "variant_requires_shipping"
    t.boolean "variant_taxable"
    t.bigint "variant_barcode"
    t.text "image_src"
    t.text "image_alt_text"
    t.boolean "gift_card"
    t.string "variant_weight_unit"
    t.string "variant_tax_code"
    t.string "collection"
    t.string "color_id"
    t.boolean "uploaded", default: false
    t.datetime "uploaded_at"
  end

  create_table "threedots_products", force: :cascade do |t|
    t.string "shopify_product_id"
    t.string "title"
    t.text "body_html"
    t.boolean "updated", default: false
    t.string "handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zobha_products", force: :cascade do |t|
    t.string "shopify_product_id"
    t.string "title"
    t.text "body_html"
    t.boolean "updated", default: false
    t.string "handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
