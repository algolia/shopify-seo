module ServiceLogger
  class << self
    def log_service_result(result, collection_id)
      if result
        puts "Collection #{collection_id} updated succesfully ! ✅"
      else
        puts "ERROR - Could not update collection #{collection_id} ❌"
      end
    end
  end
end
