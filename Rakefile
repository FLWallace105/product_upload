require 'active_record'
require 'sinatra/activerecord'
require "sinatra/activerecord/rake"
require_relative 'models/marika_product'
require_relative 'models/zobha_product'
require_relative 'models/ellie_staging_product'

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

  desc 'delete all Marika products and reset the marika_products table index'
  task :delete_all_and_reindex do |_t|
    MarikaProduct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('marika_products')
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

  desc 'delete all Zobha products and reset the zoba_products table index'
  task :delete_all_and_reindex do |_t|
    ZobhaProduct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('zobha_products')
  end
end

namespace :ellie_staging do
  desc 'saves shopify_product_id, handle, body_html, and title, from Shopify to the local database'
  task :save_all_products do |_t|
    EllieStagingProduct.setup('ELLIE_STAGING').save_all_products
    puts "#{EllieStagingProduct.count} PRODUCTS ARE IN THE DATABASE"
  end

  desc "after running the save_all_products task, this will map each local_product's body_html to the body_html of the matching product in Shopify."
  task :update_all_products_from_api do |_t|
    EllieStagingProduct.setup('ZOBHA').update_all_products_from_api
  end

  desc 'delete all Zobha products and reset the zoba_products table index'
  task :delete_all_and_reindex do |_t|
    EllieStagingProduct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('ellie_staging_products')
  end
end

namespace :db do
  task :load_config do
    require "./app"
  end
end
