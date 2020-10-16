#!/usr/bin/env ruby

require 'algoliasearch'
require 'dotenv/load'
require 'shopify_api'

require_relative '../lib/clients/shopify_api_client'
require_relative '../lib/clients/algolia_api_client'

require_relative '../lib/services/retrieve_collections'
require_relative '../lib/services/update_products_order'
require_relative '../lib/helpers/updater_helper'

puts
puts 'Initiating Update...'
puts

NUMBER_OF_PRODUCTS_TO_ORDER = 250

# assign variables
algolia_app_id = ENV['ALGOLIA_APP_ID']
algolia_search_api_key = ENV['ALGOLIA_SEARCH_API_KEY']
shopify_api_key = ENV['SHOPIFY_API_KEY']
shopify_password = ENV['SHOPIFY_PASSWORD']
shop_domain = ENV['SHOP_DOMAIN']
index_name = ENV['INDEX_NAME']

# check variables presence
%w[algolia_app_id algolia_search_api_key shopify_api_key shopify_password shop_domain index_name]
  .each do |param|
  # rubocop:disable Security/Eval
  raise ArgumentError, "missing parameter #{param}" if eval(param).blank?
  # rubocop:enable Security/Eval
end

# initate requests logger
ActiveResource::Base.logger = Logger.new('log/shopify_api.log')

# initialize Shopify client
shop_url = "https://#{shopify_api_key}:#{shopify_password}@#{shop_domain}"
shopify_api_client = ShopifyApiClient.new(shop_url)

# initialize Algolia Client
algolia_api_client = AlgoliaApiClient.new(
  application_id: algolia_app_id,
  api_key: algolia_search_api_key,
  index_name: index_name
)

# Retrieve collection ids
puts
puts 'Retrieving all collections with its products...'
puts

retrieve_collections = RetrieveCollections.new(shopify_api_client).call
smart_collections = retrieve_collections.smart_collections
custom_collections = retrieve_collections.custom_collections

puts
puts "found #{smart_collections.count} smart collections"
puts "found #{custom_collections.count} custom collections"
puts

# update collection orders

puts
puts 'Updating smart collections'
puts

# update smart collection orders
smart_collections.each do |collection|
  puts "updating positions for smart collection #{collection.id}"

  result = UpdateProductsOrder.new(
    collection: collection,
    algolia_api_client: algolia_api_client,
    shopify_api_client: shopify_api_client,
    collection_type: :smart_collection
  ).call

  UpdaterHelper.log_service_result(result, collection.id)
  puts
end

# update custom collection orders
puts
puts 'Updating custom collections'
puts

custom_collections.each do |collection|
  puts "updating postions for custom collection #{collection}"

  result = UpdateProductsOrder.new(
    collection: collection,
    algolia_api_client: algolia_api_client,
    shopify_api_client: shopify_api_client,
    collection_type: :custom_collection
  ).call

  UpdaterHelper.log_service_result(result, collection.id)
  puts
end
