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
require_relative 'services/marika_products'

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
    'hello Fam Brands'
  end

  get '/marika_products/upload_csv' do
    erb :'marika_products/upload_csv', layout: :'layouts/application'
  end

  post '/marika_products/upload_csv' do
    MarikaProducts.new.update_all_products_from_csv(params[:attachment])
  end
end
