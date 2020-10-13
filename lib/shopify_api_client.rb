class ShopifyApiClient
  def initialize(shop_url)
    @shop_url = shop_url
    open_session
  end

  def update_collect(collection_id, product_id, position)
    collect = ShopifyAPI::Collect.new
    collect.product_id = product_id
    collect.collection_id = collection_id
    collect.position = position
    collect.save
  end

  def update_smart_collection_order(collection_id, product_ids)
    smart_collection = retrieve_smart_collection(collection_id)
    smart_collection.order = product_ids
    smart_collection.save
  end

  def retrieve_smart_collection(collection_id)
    ShopifyAPI::SmartCollection.find(collection_id)
  end

  def retrieve_smart_collections
    retrieve_all('SmartCollection')
  end

  def retrieve_custom_collections
    retrieve_all('CustomCollection')
  end

  private

  def retrieve_all(resource_name)
    resource_class = "ShopifyAPI::#{resource_name}".constantize
    all_records = []
    resources = resource_class.find(:all, params: { limit: 1 })
    all_records += resources
    while resources.next_page?
      resources = resources.fetch_next_page
      all_records += resources
    end
    all_records
  end

  def open_session
    ShopifyAPI::Base.site = @shop_url
    ShopifyAPI::Base.api_version = '2020-10'
  end
end
