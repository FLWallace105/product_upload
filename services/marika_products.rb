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

    nb_pages = (product_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      products = ShopifyAPI::Product.find(:all, :params => { limit: 250, page: page })
      products.each do |product|
        puts "#{product.id} | #{product.title} | #{product.published_at}"
        # local_product = MarikaProduct.create(shopify_product_id: product.id)

        # shopify_product = ShopifyAPI::Product.find(product.id)
        # body_html = product_metafields_html(product)
        # if body_html
        #   shopify_product.body_html = body_html
        #   shopify_product.save
        #   local_product.update(body_html: body_html, status: :updated)
        # end
      end
      puts 'SLEEPING 3' # sleep to prevent 8 minute timeout?
      sleep 3
    end
    puts "#{MarikaProduct.updated.count} PRODUCTS UPDATED"
    puts "#{MarikaProduct.not_updated.count} PRODUCTS DID NOT UPDATE"
  end

  def update_all_products_from_csv(file)
    arr_of_arrs = CSV.read(file["tempfile"].path)
    puts arr_of_arrs
  end

  private

  def product_metafields_html(product)
    metafield_data = ShopifyAPI::Metafield.all(params: { resource: 'products', resource_id: product.id, fields: 'key, value' })

    if metafield_data.empty?
      puts "NO METADATA FOR PRODUCT_ID: #{product.id}"
    else
      unordered_list = unordered_list(metafield_data)

      # this is what you'll do instead once this is dialed in:
      # product.update(body: unordered_list, status: :updated)
    end

    unordered_list || nil
  end

  def unordered_list(metafield_data)
    ul = "<ul>"

    metafield_data.each do |metafield_object|
      next if metafield_object.attributes["key"] == "discount_EMPLOYEE"
      li = '<li>' + metafield_object.attributes["value"] + '</li>'
      ul << li
    end

    ul << '</ul>'
  end
end
