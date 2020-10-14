require 'algoliasearch'
require 'dotenv/load'
require 'shopify_api'

require_relative './lib/clients/shopify_api_client'
require_relative './lib/services/retrieve_collection_ids'
require_relative './lib/services/update_products_order'
require_relative './lib/loggers/service_logger'

puts
puts 'Initiating Update...'
puts

# assign variables
algolia_app_id = ENV['ALGOLIA_APP_ID']
algolia_api_key = ENV['ALGOLIA_API_KEY']
shopify_api_key = ENV['SHOPIFY_API_KEY']
shopify_password = ENV['SHOPIFY_PASSWORD']
shop_name = ENV['SHOP_NAME']
index_name = ENV['INDEX_NAME']

# initate requests logger
ActiveResource::Base.logger = Logger.new('log/shopify_api.log')

# initialize Shopify client
shop_url = "https://#{shopify_api_key}:#{shopify_password}@#{shop_name}.myshopify.com"
shopify_api_client = ShopifyApiClient.new(shop_url)

# initialize Algolia Client
Algolia.init(application_id: algolia_app_id, api_key: algolia_api_key)
algolia_index = Algolia::Index.new(index_name)

# Retrieve collection ids
puts
puts 'Retrieving all collection ids...'
puts

retrieve_collection_ids = RetrieveCollectionIds.new(shopify_api_client).call
smart_collection_ids = retrieve_collection_ids.smart_collection_ids
custom_collection_ids = retrieve_collection_ids.custom_collection_ids

puts "found #{smart_collection_ids.count} smart collections"
puts "found #{custom_collection_ids.count} custom collections"

# updating collection orders

puts
puts 'Updating smart collections'
puts

# update smart collection orders
smart_collection_ids.each do |collection_id|
  puts "updating positions for smart collection #{collection_id}"

  sleep 1 if ShopifyAPI.credit_left < 10

  result = UpdateProductsOrder.new(
    collection_id: collection_id,
    algolia_index: algolia_index,
    shopify_api_client: shopify_api_client,
    collection_type: :smart_collection
  ).call

  ServiceLogger.log_service_result(result, collection_id)
  puts
end

# update custom collection orders
puts
puts 'Updating custom collections'
puts

custom_collection_ids.each do |collection_id|
  puts "updating postions for custom collection #{collection_id}"

  sleep 1 if ShopifyAPI.credit_left < 10

  result = UpdateProductsOrder.new(
    collection_id: collection_id,
    algolia_index: algolia_index,
    shopify_api_client: shopify_api_client,
    collection_type: :custom_collection
  ).call

  ServiceLogger.log_service_result(result, collection_id)
  puts
end
