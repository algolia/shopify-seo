class UpdateProductsOrder
  def initialize(collection_id:, collection_type:, algolia_index:, shopify_api_client:)
    @collection_id = collection_id
    @collection_type = collection_type
    @algolia_index = algolia_index
    @shopify_api_client = shopify_api_client
    @collection_product_ids = Set.new
  end

  def call
    fetch_collection_product_ids
    update_products_order
  end

  private

  def fetch_collection_product_ids
    @algolia_index.browse(query: '', filters: query_filter) do |hit|
      @collection_product_ids << hit['id']
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
    @collection_product_ids.each_with_index do |product_id, idx|
      puts "placing product #{product_id} at position #{idx}"

      @shopify_api_client.update_collect(@collection_id, product_id, idx)
    end
  end

  def update_smart_collection_products_order
    @shopify_api_client.update_smart_collection_order(
      @collection_id, @collection_product_ids.to_a
    )
  end

  def query_filter
    "collection_ids:#{@collection_id}"
  end
end
