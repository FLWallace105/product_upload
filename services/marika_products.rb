require 'dotenv'
require 'shopify_api'
require './models/marika_product'
require 'csv'
require 'pry'

class MarikaProducts
  def initialize
    Dotenv.load
    @apikey = ENV['MARIKA_API_KEY']
    @password = ENV['MARIKA_PASSWORD']
    @shopname = ENV['MARIKA_SHOPNAME']
    ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
  end

  def save_all_products
    product_count = ShopifyAPI::Product.count

    nb_pages = (product_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      products = ShopifyAPI::Product.find(:all, :params => { limit: 250, page: page })
      products.each do |product|
        next if MarikaProduct.find_by_shopify_product_id(product.id)
        MarikaProduct.create(shopify_product_id: product.id, handle: product.handle)
      end
    end
  end

  def update_all_products_from_api
    puts "We have #{MarikaProduct.count} products"
    updated_count = 0
    not_updated_count = 0

    MarikaProduct.find_each do |local_product|
      shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)
      body_html = product_metafields_html(shopify_product)

      if body_html
        shopify_product.body_html = body_html
        if shopify_product.save
          local_product.update(body_html: body_html, status: :updated)
          updated_count += 1
        else
          not_updated_count += 1
          local_product.update(status: :skipped)
        end
      else
        local_product.update(status: :skipped)
        not_updated_count += 1
      end
    end
    puts "#{updated_count} PRODUCTS UPDATED"
    puts "#{not_updated_count} PRODUCTS DID NOT UPDATE"
  end

  def update_all_products_from_csv(file)
    not_updated_count = 0
    updated_count = 0
    save_all_products

    CSV.foreach(file["tempfile"].path, headers: false) do |row|
      row.compact!
      next if row[0] == 'product_id' # skip the header
      local_product = MarikaProduct.find_by_handle(row[0].downcase)

      shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)
      body_html = csv_unordered_list(row)
      shopify_product.body_html = body_html

      if shopify_product.save
        local_product.update(body_html: body_html, status: :updated)
        updated_count += 1
      else
        not_updated_count += 1
        local_product.update(status: :skipped)
      end
    end

    { updated: updated_count, not_updated: not_updated_count }
  end

  def add_variants_from_csv(file)
    not_updated_count = 0
    updated_count = 0
    save_all_products

    CSV.foreach(file["tempfile"].path, headers: true, header_converters: :symbol) do |row|
      raw_args = row.to_hash
      needed_args = raw_args.slice(
        :title,
        :variant_price,
        :variant_sku,
        :variant_inventory_policy,
        :variant_compare_at_price,
        :variant_fulfillment_service,
        :option1_value,
        :option2_value,
        :option3_value,
        :variant_taxable,
        :variant_barcode,
        :variant_grams,
        :variant_inventory_qty,
        :variant_weight_unit,
        :variant_requires_shipping
      )

      new_keys_args = needed_args.map { |key, value| [key_map[key], value] }.to_h
      new_keys_args[:grams] = new_keys_args[:grams].to_i
      new_keys_args[:inventory_quantity] = new_keys_args[:inventory_quantity].to_i
      local_product = MarikaProduct.find_by_handle(raw_args[:handle])
      new_keys_args[:product_id] = local_product.shopify_product_id
      shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)
      variant = ShopifyAPI::Variant.new(**new_keys_args)
      shopify_product.variants << variant

      if shopify_product.save
        updated_count += 1
      else
        not_updated_count += 1
      end
    end

    { updated: updated_count, not_updated: not_updated_count }
  end

  private

  def product_metafields_html(product)
    metafield_data = ShopifyAPI::Metafield.all(params: { resource: 'products', resource_id: product.id, fields: 'key, value' })

    if metafield_data.empty?
      puts "NO METADATA FOR PRODUCT_ID: #{product.id}"
    else
      unordered_list = api_unordered_list(metafield_data)
    end

    unordered_list || nil
  end

  def api_unordered_list(metafield_data)
    ul = "<ul>"

    metafield_data.each do |metafield_object|
      next if metafield_object.attributes["key"] == "discount_EMPLOYEE"
      li = '<li>' + metafield_object.attributes["value"] + '</li>'
      ul << li
    end

    ul << '</ul>'
  end

  def csv_unordered_list(array)
    ul = "<ul>"

    array[1..-1].each do |string|
      li = '<li>' + string + '</li>'
      ul << li
    end

    ul << '</ul>'
  end

  def key_map
    {
      title: :title,
      variant_price: :price,
      variant_sku: :sku,
      variant_inventory_policy: :inventory_policy,
      variant_compare_at_price: :compare_at_price,
      variant_fulfillment_service: :fulfillment_service,
      option1_value: :option1,
      option2_value: :option2,
      option3_value: :option3,
      variant_taxable: :taxable,
      variant_barcode: :barcode,
      variant_grams: :grams,
      variant_inventory_qty: :inventory_quantity,
      variant_weight_unit: :weight_unit,
      variant_requires_shipping: :requires_shipping
    }
  end
end
