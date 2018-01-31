require 'active_record'
require 'sinatra/activerecord'
require "sinatra/activerecord/rake"
require_relative 'services/marika_products'

namespace :marika do
  desc 'list current products'
  task :current_products do |_t|
    MarikaProducts.new.count_products
  end

  desc 'find all products'
  task :update_all_products_from_api do |_t|
    MarikaProducts.new.update_all_products_from_api
  end

  desc 'save all products'
  task :save_all_products do |_t|
    MarikaProducts.new.save_all_products
    puts "#{MarikaProduct.count} PRODUCTS ARE IN THE DATABASE"
  end
end

namespace :db do
  task :load_config do
    require "./app"
  end
end
