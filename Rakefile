require 'active_record'
require 'sinatra/activerecord'
require "sinatra/activerecord/rake"
require_relative 'models/marika_product'
require_relative 'models/zobha_product'

namespace :marika do
  desc 'saves shopify_product_id, handle, body_html, and title, from Shopify to the local database'
  task :save_all_products do |_t|
    MarikaProduct.setup('MARIKA').save_all_products
    puts "#{MarikaProduct.count} PRODUCTS ARE IN THE DATABASE"
  end

  desc "after running the save_all_products task, this will map each local_product's body_html to the body_html of the matching product in Shopify."
  task :update_all_products_from_api do |_t|
    MarikaProduct.setup('MARIKA').update_all_products_from_api
  end
end

namespace :zobha do
  desc 'saves shopify_product_id, handle, body_html, and title, from Shopify to the local database'
  task :save_all_products do |_t|
    ZobhaProduct.setup('ZOBHA').save_all_products
    puts "#{ZobhaProduct.count} PRODUCTS ARE IN THE DATABASE"
  end

  desc "after running the save_all_products task, this will map each local_product's body_html to the body_html of the matching product in Shopify."
  task :update_all_products_from_api do |_t|
    ZobhaProduct.setup('ZOBHA').update_all_products_from_api
  end
end

namespace :db do
  task :load_config do
    require "./app"
  end
end
