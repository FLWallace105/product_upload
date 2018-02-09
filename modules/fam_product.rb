require 'dotenv'
require 'shopify_api'
require 'csv'
require 'pry'

module FamProduct
  def setup(store)
    Dotenv.load
    ShopifyAPI::Base.site = "https://#{ENV["#{store}_API_KEY"]}:#{ENV["#{store}_PASSWORD"]}@#{ENV["#{store}_SHOPNAME"]}.myshopify.com/admin"
    @not_updated_count = 0
    @updated_count = 0
    self
  end

  def save_all_products
    product_count = ShopifyAPI::Product.count

    nb_pages = (product_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      puts "CREDITS LEFT: #{ShopifyAPI.credit_left}"
      products = ShopifyAPI::Product.find(:all, :params => { limit: 250, page: page })
      products.each do |product|
        shopify_api_throttle
        next if find_by_shopify_product_id(product.id)
        local_product = create(
          shopify_product_id: product.id,
          handle: product.handle,
          body_html: product_metafields_html(product),
          title: product.title
        )
        puts "CREATED: #{local_product.title}, #{local_product.shopify_product_id}" if local_product&.persisted?
      end
    end
  end

  def update_all_products_from_api
    puts "We have #{count} products"

    find_each do |local_product|
      shopify_api_throttle
      shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)

      if local_product.body_html.present?
        shopify_product.body_html = local_product.body_html
        save_and_increase_count(local_product, shopify_product)
      else
        local_product.update(updated: false)
        @not_updated_count += 1
        puts "DID NOT UPDATE: #{shopify_product.title}, #{shopify_product.id}"
      end
    end
    puts "#{@updated_count} PRODUCTS UPDATED"
    puts "#{@not_updated_count} PRODUCTS DID NOT UPDATE"
  end

  def update_all_products_from_csv(file)
    return_data = return_data_hash
    return return_data unless file
    save_all_products
    read_handles = []

    CSV.foreach(file["tempfile"].path, headers: false) do |row|
      row.compact!
      next if row[0] == 'product_id' # skip the header
      next if read_handles.include?(row[0].downcase)
      read_handles << row[0].downcase
      local_product = find_by_handle(row[0].downcase)
      if local_product.nil?
        return_data[:not_updated] += 1
        return_data[:handles_not_found] << row[0].downcase
        next
      end
      shopify_api_throttle
      shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)
      body_html = csv_unordered_list(row)
      shopify_product.body_html = body_html

      if shopify_product.save
        local_product.update(body_html: body_html, updated: true)
        return_data[:updated] += 1
      else
        local_product.update(updated: false)
        return_data[:products_not_updated] << local_product.shopify_product_id
        return_data[:not_updated] += 1
      end
    end

    return_data
  end

  # TODO:: Delete method
  # def create_product_from_csv(file)
  #   return_data = { created: 0, not_created: 0 }
  #   return return_data unless file
  #   read_handles = []
  #
  #   CSV.foreach(file["tempfile"].path, headers: true, header_converters: :symbol) do |row|
  #     raw_args = row.to_hash
  #     next if read_handles.include?(raw_args[:handle])
  #     read_handles << raw_args[:handle]
  #
  #     # argument manipulation:
  #     needed_args = product_needed_args(raw_args)
  #     new_keys_args = needed_args.map { |key, value| [product_key_map[key], value] }.to_h
  #     new_keys_args[:handle] = raw_args[:handle].downcase
  #     new_keys_args[:published_at] = nil if raw_args[:published] == "0"
  #     shopify_api_throttle
  #     shopify_product = ShopifyAPI::Product.new(**new_keys_args)
  #     shopify_collection = ShopifyAPI::CustomCollection.where(title: raw_args[:title]).first
  #     if shopify_collection
  #       shopify_collection.add_product(shopify_product)
  #     end
  #     if shopify_product.save
  #       return_data[:created] += 1
  #       create(
  #         shopify_product_id: shopify_product.id,
  #         handle: shopify_product.handle,
  #         body_html: product_metafields_html(shopify_product),
  #         title: shopify_product.title
  #       )
  #     else
  #       return_data[:not_created] += 1
  #     end
  #   end
  #
  #   return_data
  # end

  def add_variants_from_csv(file)
    return_data = return_data_hash
    return return_data unless file
    save_all_products
    read_handles = []

    CSV.foreach(file["tempfile"].path, headers: true, header_converters: :symbol) do |row|
      raw_args = row.to_hash
      next if read_handles.include?(raw_args[:handle])
      read_handles << raw_args[:handle]

      # argument manipulation:
      needed_args = product_variant_needed_args(raw_args)
      new_keys_args = needed_args.map { |key, value| [product_variant_key_map[key], value] }.to_h
      new_keys_args[:grams] = new_keys_args[:grams].to_i
      new_keys_args[:inventory_quantity] = new_keys_args[:inventory_quantity].to_i

      local_product = find_by_handle(raw_args[:handle])
      if local_product.nil?
        return_data[:not_updated] += 1
        return_data[:handles_not_found] << raw_args[:handle]
        next
      end
      new_keys_args[:product_id] = local_product.shopify_product_id

      shopify_api_throttle
      shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)
      variant = ShopifyAPI::Variant.new(**new_keys_args)
      shopify_product.variants << variant

      if shopify_product.save
        local_product.update(updated: true)
        return_data[:updated] += 1
      else
        local_product.update(updated: false)
        return_data[:products_not_updated] << local_product.shopify_product_id
        return_data[:not_updated] += 1
      end
    end

    return_data
  end

  private

  def product_metafields_html(product)
    metafield_data = ShopifyAPI::Metafield.all(params: { resource: 'products', resource_id: product.id, fields: 'key, value' })

    if metafield_data.empty?
      puts "NO METADATA FOR SHOPIFY_PRODUCT_ID: #{product.id}"
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

  def save_and_increase_count(local_product, shopify_product)
    if shopify_product.save
      @updated_count += 1
      local_product.update(updated: true)
      puts "UPDATED: #{shopify_product.title}, #{shopify_product.id}"
    else
      @not_updated_count += 1
      local_product.update(updated: false)
      puts "DID NOT UPDATE: #{shopify_product.title}, #{shopify_product.id}"
    end
  end

  def product_variant_needed_args(raw_args)
    raw_args.slice(
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
  end

  def product_variant_key_map
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

  def return_data_hash
    {
      updated: 0,
      not_updated: 0,
      handles_not_found: [],
      products_not_updated: []
    }
  end

  def shopify_api_throttle
    return if ShopifyAPI.credit_left > 5
    puts "CREDITS LEFT: #{ShopifyAPI.credit_left}"
    puts "SLEEPING 10"
    sleep 10
  end

  # TODO:: delte these: methods
  # def product_needed_args(raw_args)
  #   raw_args.slice(
  #     :handle,
  #     :title,
  #     :vendor,
  #     :type
  #   )
  # end
  #
  # def product_key_map
  #   {
  #     handle: :handle,
  #     title: :title,
  #     vendor: :vendor,
  #     type: :product_type
  #   }
  # end
end
