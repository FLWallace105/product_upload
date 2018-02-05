require 'sinatra'
require "sinatra/reloader"
require 'active_support/all'
require "sinatra/activerecord"
require 'sinatra/flash'
require "rake"
require 'dotenv'
require 'pry' if development? || test?
require_relative 'helpers/view_helper'
require_relative 'helpers/route_helper'
require_relative 'models/marika_product'
require_relative 'models/zobha_product'

class FamProductsUpdate < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Flash
  helpers ViewHelper
  helpers RouteHelper

  configure do
    enable :logging
    enable :sessions
    Dotenv.load
    set :server, :puma
  end

  configure :development do
    register Sinatra::Reloader
    also_reload '/public/**/*'
  end

  get '/' do
    'Hello Fam Brands'
  end

  get '/marika_products/upload_products_csv' do
    erb :'marika_products/upload_products_csv', layout: :'layouts/application'
  end

  post '/marika_products/upload_products_csv' do
    result = MarikaProduct.setup('MARIKA').update_all_products_from_csv(params[:attachment])
    flash[:success] = "#{result[:updated]} products updated and #{result[:not_updated]} did not update."
    redirect '/marika_products/upload_products_csv'
  end

  get '/marika_products/upload_variants_csv' do
    erb :'marika_products/upload_variants_csv', layout: :'layouts/application'
  end

  post '/marika_products/upload_variants_csv' do
    result = MarikaProduct.setup('MARIKA').add_variants_from_csv(params[:attachment])
    flash[:success] = "#{result[:updated]} products updated and #{result[:not_updated]} did not update."
    redirect '/marika_products/upload_variants_csv'
  end

  get '/zobha_products/upload_products_csv' do
    erb :'zobha_products/upload_products_csv', layout: :'layouts/application'
  end

  post '/zobha_products/upload_products_csv' do
    result = ZobhaProduct.setup('ZOBHA').update_all_products_from_csv(params[:attachment])
    flash[:success] = "#{result[:updated]} products updated and #{result[:not_updated]} did not update."
    redirect '/zobha_products/upload_products_csv'
  end

  get '/zobha_products/upload_variants_csv' do
    erb :'zobha_products/upload_variants_csv', layout: :'layouts/application'
  end

  post '/zobha_products/upload_variants_csv' do
    result = ZobhaProduct.setup('ZOBHA').add_variants_from_csv(params[:attachment])
    flash[:success] = "#{result[:updated]} products updated and #{result[:not_updated]} did not update."
    redirect '/zobha_products/upload_variants_csv'
  end
end
