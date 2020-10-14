class UpdateProductsOrder
  def initialize(collection_id:, collection_type:, algolia_index:, shopify_api_client:)
    @collection_id = collection_id
    @collection_type = collection_type
    @algolia_index = algolia_index
    @shopify_api_client = shopify_api_client
    @ordered_collection_product_ids = Set.new
  end

  def call
    fetch_ordered_collection_product_ids
    log_algolia_products_order
    update_products_order
  end

  private

  def fetch_ordered_collection_product_ids
    @algolia_index.browse(query: '', filters: query_filter) do |hit|
      @ordered_collection_product_ids << hit['id']
    end
  end

  def update_products_order
    case @collection_type
    when :smart_collection
      update_smart_collection_products_order
    when :custom_collection
      update_custom_collection_products_order
    else
      raise "Unknown collection type #{@collection_type}"
    end
  end

  def update_custom_collection_products_order
    @shopify_api_client.update_custom_collection_order(@collection_id, new_collects_body)
  end

  def update_smart_collection_products_order
    @shopify_api_client.update_smart_collection_order(
      @collection_id, @ordered_collection_product_ids.to_a
    )
  end

  def new_collects_body
    @ordered_collection_product_ids.map.with_index do |product_id, idx|
      {
        # the id of the collect needs to be part of the payload if we're only updating the position
        id: collection_collects_id_by_product_id[product_id],
        position: idx + 1,
        product_id: product_id,
        collection_id: @collection_id
      }
    end
  end

  def collection_collects_id_by_product_id
    # [{ 'product-id' => 'collect-id'}]
    Hash[collection_collects.map { |collect| [collect.product_id, collect.id] }]
  end

  def collection_collects
    @collection_collects ||= @shopify_api_client.retrieve_collects_for_collection(@collection_id)
  end

  def query_filter
    "collection_ids:#{@collection_id}"
  end

  def log_algolia_products_order
    puts "#{@ordered_collection_product_ids.to_a} " \
      "is the Algolia order for collection #{@collection_id}"
  end
end
