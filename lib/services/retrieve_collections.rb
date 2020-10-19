class RetrieveCollections
  def initialize(shopify_api_client)
    @shopify_api_client = shopify_api_client
  end

  def call
    OpenStruct.new(
      smart_collections: filtered_collections(:smart_collections),
      custom_collections: filtered_collections(:custom_collections)
    )
  end

  private

  def augment_collection(collection)
    puts "retrieving product ids for collection #{collection.id}"
    collection.tap do |c|
      c.product_ids = @shopify_api_client
                      .retrieve_collection_products(c.id).map(&:id)
    end
  end

  def smart_collections_with_product_ids
    smart_collections.map do |collection|
      augment_collection(collection)
    end
  end

  def custom_collections_with_product_ids
    custom_collections.map do |collection|
      augment_collection(collection)
    end
  end

  def custom_collections
    @shopify_api_client.retrieve_custom_collections
  end

  def smart_collections
    @shopify_api_client.retrieve_smart_collections
  end

  def filtered_collections(collection_type)
    collections_with_product_ids(collection_type).reject do |collection|
      skip_collection?(collection)
    end
  end

  def collections_with_product_ids(collection_type)
    if collection_type == :smart_collections
      smart_collections_with_product_ids
    elsif collection_type == :custom_collections
      custom_collections_with_product_ids
    end
  end

  # We retrieve all the store collections except the ones we don't index in Algolia.
  # We don't index a collection in Algolia if :
  # - it is unpublished or is published in the future
  # - it has '[hidden]' in its title
  # - it does not have any products
  # - it is the frontpage collection
  def skip_collection?(collection)
    collection.published_at.nil? ||
      Time.parse(collection.published_at).utc > Time.now.utc ||
      collection.handle == 'frontpage' ||
      collection.title.include?('[hidden]') ||
      collection.product_ids.count.zero?
  end
end
