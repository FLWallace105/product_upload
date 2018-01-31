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

  def count_products
    product_count = ShopifyAPI::Product.count
    puts "We have #{product_count} products"
    bad_product = 0
    visible_products = 0

    nb_pages = (product_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      products = ShopifyAPI::Product.find(:all, :params => { :limit => 250, :page => page })
      products.each do |product|
        puts "#{product.id} | #{product.title} | #{product.published_at}"
        visible_products += 1 if product.published_at.nil?
        variants = product.variants
        variants.each do |variant|
          puts "#{product.title} -- #{variant.title}, #{variant.inventory_management}, #{variant.inventory_policy}"
          puts "#{variant.sku}, #{variant.inventory_quantity}, #{variant.old_inventory_quantity}"
          if variant.inventory_management != 'shopify' && variant.inventory_policy != 'deny'
            bad_product += 1
          end
        end
      end
      puts 'sleeping 3'
      sleep 3
    end
    puts "We have #{bad_product} bad products"
    puts "we have #{visible_products} visible products"
  end

  def update_all_products_from_api
    product_count = ShopifyAPI::Product.count
    puts "We have #{product_count} products"
    updated_count = 0
    not_updated_count = 0
    save_all_products

    nb_pages = (product_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      products = ShopifyAPI::Product.find(:all, :params => { limit: 250, page: page })
      products.each do |product|
        puts "#{product.id} | #{product.title} | #{product.published_at}"
        local_product = MarikaProduct.find_by_shopify_product_id(product.id)
        shopify_product = ShopifyAPI::Product.find(product.id)
        body_html = product_metafields_html(product)

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
      puts 'SLEEPING 3' # sleep to prevent 8 minute timeout?
      sleep 3
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

      # shopify_product = ShopifyAPI::Product.find(local_product.shopify_product_id)
      body_html = csv_unordered_list(row)
      # shopify_product.body_html = body_html

      # shopify_product = ShopifyAPI::Product.find(8992544009) # this line is for test purposes only

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
      new_args = raw_args.map {|key, value| [key_map[key], value] }.to_h
      new_args.slice(
        :title,
        :price
      )
      binding.pry
      # local_product = MarikaProduct.find_by_handle(row[0].downcase)
      # shopify_product = ShopifyAPI::Product.find('10155033481') # for test only
      variant = ShopifyAPI::Variant.new
      variant.product_id = '10155033481' # local_product.shopify_product_id
      variant.price = 10
      variant.sku = 'SKU111'
      variant.size = 'XS'
      variant.save
      if variant.save
        updated_count += 1
      else
        not_updated_count += 1
      end
    end

    { updated: updated_count, not_updated: not_updated_count }
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
    { handle: :handle,
      title: :title,
      body_html: :body_html,
      vendor: :vendor,
      type: :type,
      tags: :tags,
      published: :published,
      option1_name: :option1_name,
      option1_value: :option1,
      option2_name: :option2_name,
      option2_value: :option2,
      option3_name: :option3_name,
      option3_value: :option3,
      variant_sku: :sku,
      variant_grams: :grams,
      variant_inventory_tracker: :variant_inventory_tracker,
      variant_inventory_qty: :inventory_quantity,
      variant_inventory_policy: :inventory_policy,
      variant_fulfillment_service: :fulfillment_service,
      variant_price: :price,
      variant_compare_at_price: :compare_at_price,
      variant_requires_shipping: :requires_shipping,
      variant_taxable: :taxable,
      variant_barcode: :barcode,
      image_src: :image_src,
      image_alt_text: :image_alt_text,
      gift_card: :gift_card,
      google_shopping__mpn: :google_shopping__mpn,
      google_shopping__age_group: :google_shopping__age_group,
      google_shopping__gender: :google_shopping__gender,
      google_shopping__google_product_category: :google_shopping__google_product_category,
      seo_title: :seo_title,
      seo_description: :seo_description,
      google_shopping__adwords_grouping: :google_shopping__adwords_grouping,
      google_shopping__adwords_labels: :google_shopping__adwords_labels,
      google_shopping__condition: :google_shopping__condition,
      google_shopping__custom_product: :google_shopping__custom_product,
      google_shopping__custom_label_0: :google_shopping__custom_label_0,
      google_shopping__custom_label_1: :google_shopping__custom_label_1,
      google_shopping__custom_label_2: :google_shopping__custom_label_2,
      google_shopping__custom_label_3: :google_shopping__custom_label_3,
      google_shopping__custom_label_4: :google_shopping__custom_label_4,
      variant_image: :variant_image,
      variant_weight_unit: :weight,
      variant_tax_code: :variant_tax_code,
      collection: :collection,
      color_id: :color_id }
  end
end

# Steps to add a new variant:
# shopify_product = ShopifyAPI::Product.find('10155033481')
# args = { "product_id"=>'10155033481',
#     "title"=>"RASPBERRY / Test",
#     "price"=>"9.99",
#     "sku"=>"SKUTEST",
#     "position"=>5,
#     "inventory_policy"=>"deny",
#     "compare_at_price"=>nil,
#     "fulfillment_service"=>"manual",
#     "inventory_management"=>"shopify",
#     "option1"=>"RASPBERRY2",
#     "option2"=>"XL1",
#     "option3"=>'soft',
#     "taxable"=>true,
#     "barcode"=>"",
#     "grams"=>0,
#     "image_id"=>22708761609,
#     "inventory_quantity"=>15,
#     "weight"=>0.0,
#     "weight_unit"=>"lb",
#     "inventory_item_id"=>31394762313,
#     "old_inventory_quantity"=>15,
#     "requires_shipping"=>true}
#
#   variant = ShopifyAPI::Variant.new(**args.symbolize_keys)
#
#   shopify_product.variants << variant
#
#   shopify_product.save
