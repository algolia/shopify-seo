module UpdaterHelper
  class << self
    def log_service_result(result, collection_id)
      if result
        puts "Collection #{collection_id} updated succesfully ! ✅"
      else
        puts "ERROR - Could not update collection #{collection_id} ❌"
      end
    end

    def number_of_products_to_order
      ENV['NUMBER_OF_PRODUCTS_TO_ORDER'] || 100
    end
  end
end
