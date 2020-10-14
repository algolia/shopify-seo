class RetrieveCollectionIds
  attr_reader :context

  def initialize(shopify_api_client)
    @shopify_api_client = shopify_api_client
    @context = OpenStruct.new
  end

  def call
    context.smart_collection_ids = smart_collection_ids
    context.custom_collection_ids = custom_collection_ids
    context
  end

  private

  def smart_collection_ids
    smart_collections.reject do |collection|
      sleep 1 if ShopifyAPI.credit_left < 10
      skip_collection?(collection)
    end.map(&:id)
  end

  def smart_collections
    @shopify_api_client.retrieve_smart_collections
  end

  def custom_collection_ids
    custom_collections.reject do |collection|
      sleep 1 if ShopifyAPI.credit_left < 10
      skip_collection?(collection)
    end.map(&:id)
  end

  def skip_collection?(collection)
    collection.published_at.nil? ||
      Time.parse(collection.published_at).utc > Time.now.utc ||
      collection.handle == 'frontpage' ||
      collection.title.include?('[hidden]') ||
      collection.products.count.zero?
  end

  def custom_collections
    @shopify_api_client.retrieve_custom_collections
  end
end
