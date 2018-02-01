require 'active_record'
require 'sinatra/activerecord'
require "sinatra/activerecord/rake"
require_relative 'services/marika_products'

namespace :marika do
  desc 'save all products'
  task :save_all_products do |_t|
    MarikaProducts.new.save_all_products
    puts "#{MarikaProduct.count} PRODUCTS ARE IN THE DATABASE"
  end
  
  desc 'after running the save_all_products task, this will update all products body_html via the product metafield data in shopify'
  task :update_all_products_from_api do |_t|
    MarikaProducts.new.update_all_products_from_api
  end
end

namespace :db do
  task :load_config do
    require "./app"
  end
end
