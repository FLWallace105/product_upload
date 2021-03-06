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
require_relative 'models/ellie_staging_product'
require_relative 'models/threedots_product'
require_relative 'models/ellie_product'

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
    @username = ENV['USERNAME']
    @password = ENV['PASSWORD']
  end

  configure :development do
    register Sinatra::Reloader
    also_reload '/public/**/*'
  end

  
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == @username && password == @password
  end
  

  get '/' do
    'Hello Fam Brands'
  end

  get '/marika_products/upload_products_csv' do
    erb :'marika_products/upload_products_csv', layout: :'layouts/application'
  end

  post '/marika_products/upload_products_csv' do
    result = MarikaProduct.setup('MARIKA').update_all_products_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/marika_products/upload_products_csv'
  end

  get '/marika_products/upload_variants_csv' do
    erb :'marika_products/upload_variants_csv', layout: :'layouts/application'
  end

  post '/marika_products/upload_variants_csv' do
    result = MarikaProduct.setup('MARIKA').add_variants_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/marika_products/upload_variants_csv'
  end

  get '/zobha_products/upload_products_csv' do
    erb :'zobha_products/upload_products_csv', layout: :'layouts/application'
  end

  post '/zobha_products/upload_products_csv' do
    result = ZobhaProduct.setup('ZOBHA').update_all_products_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/zobha_products/upload_products_csv'
  end

  get '/zobha_products/upload_variants_csv' do
    erb :'zobha_products/upload_variants_csv', layout: :'layouts/application'
  end

  post '/zobha_products/upload_variants_csv' do
    result = ZobhaProduct.setup('ZOBHA').add_variants_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/zobha_products/upload_variants_csv'
  end

  #routes below are added for Threedots
  get '/threedots_products/upload_products_csv' do
    erb :'threedots_products/upload_products_csv', layout: :'layouts/application'
  end

  post '/threedots_products/upload_products_csv' do
    result = ThreedotsProduct.setup('THREEDOTS').update_all_products_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/threedots_products/upload_products_csv'
  end

  get '/threedots_products/upload_variants_csv' do
    erb :'threedots_products/upload_variants_csv', layout: :'layouts/application'
  end

  post '/threedots_products/upload_variants_csv' do
    result = ThreedotsProduct.setup('THREEDOTS').add_variants_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/threedots_products/upload_variants_csv'
  end

  #routes below are added for Ellie
  get '/ellie_products/upload_products_csv' do
    erb :'ellie_products/upload_products_csv', layout: :'layouts/application'
  end

  post '/ellie_products/upload_products_csv' do
    result = EllieProduct.setup('ELLIE').update_all_products_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/ellie_products/upload_products_csv'
  end

  get '/ellie_products/upload_variants_csv' do
    erb :'ellie_products/upload_variants_csv', layout: :'layouts/application'
  end

  post '/ellie_products/upload_variants_csv' do
    result = EllieProduct.setup('ELLIE').add_variants_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/ellie_products/upload_variants_csv'
  end




  # The Routes Below Are For Testing
  get '/ellie_staging/upload_products_csv' do
    erb :'ellie_staging/upload_products_csv', layout: :'layouts/application'
  end

  post '/ellie_staging/upload_products_csv' do
    result = EllieStagingProduct.setup('ELLIE_STAGING').update_all_products_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/ellie_staging/upload_products_csv'
  end

  get '/ellie_staging/upload_variants_csv' do
    erb :'ellie_staging/upload_variants_csv', layout: :'layouts/application'
  end

  post '/ellie_staging/upload_variants_csv' do
    result = EllieStagingProduct.setup('ELLIE_STAGING').add_variants_from_csv(params[:attachment])
    flash[:success] = updated_product_via_csv(result)
    redirect '/ellie_staging/upload_variants_csv'
  end


end
