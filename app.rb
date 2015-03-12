require 'sinatra'
require 'slim'
require_relative 'app/shop'
require_relative 'app/scraper'

get '/' do
  @shops = Scraper.all_shops.map(&:to_json)
  slim :index
end
