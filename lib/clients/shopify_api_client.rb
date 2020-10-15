class ShopifyApiClient
  def initialize(shop_url)
    @shop_url = shop_url
    open_session
  end

  def update_custom_collection_order(collection_id, collects)
    custom_collection = retrieve_custom_collection(collection_id)
    if custom_collection.sort_order != 'manual'
      # the new sort order needs to be persisted before updating the products order
      custom_collection.sort_order = 'manual'
      custom_collection.save
    end
    custom_collection.collects = collects
    custom_collection.save
  end

  def update_smart_collection_order(collection_id, product_ids)
    smart_collection = retrieve_smart_collection(collection_id)
    # I got inspired by the gem `order` method on `SmartCollection` class but changed
    # it to pass the parameters in the request body and not the URL, otherwise we get
    # a 414 URI too long error. It is not in the Shopify docs but it seems to work.
    smart_collection.send(
      :load_attributes_from_response,
      smart_collection.put(:order, {}, { sort_order: 'manual', products: product_ids }.to_json)
    )
  end

  def retrieve_smart_collection(collection_id)
    ShopifyAPI::SmartCollection.find(collection_id)
  end

  def retrieve_custom_collection(collection_id)
    ShopifyAPI::CustomCollection.find(collection_id)
  end

  def retrieve_collects_for_collection(collection_id)
    retrieve_all('Collect', extra_params: { collection_id: collection_id })
  end

  def retrieve_products_for_collection(collection_id)
    retrieve_all('Product', extra_params: { collection_id: collection_id })
  end

  def retrieve_smart_collections
    retrieve_all('SmartCollection')
  end

  def retrieve_custom_collections
    retrieve_all('CustomCollection')
  end

  private

  def retrieve_all(resource_name, extra_params: {})
    resource_class = "ShopifyAPI::#{resource_name}".constantize
    all_records = []
    resources = resource_class.find(:all, params: extra_params.merge(limit: 250))
    all_records += resources
    while resources.next_page?
      resources = resources.fetch_next_page
      all_records += resources
      sleep 1 if ShopifyAPI.credit_left < 10
    end
    all_records
  end

  def open_session
    ShopifyAPI::Base.site = @shop_url
    ShopifyAPI::Base.api_version = '2020-10'
  end
end
