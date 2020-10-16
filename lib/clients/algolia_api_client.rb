class AlgoliaApiClient
  def initialize(application_id:, api_key:, index_name:)
    @application_id = application_id
    @api_key = api_key
    init_client
    @index = Algolia::Index.new(index_name)
  end

  def search(query, params = {})
    @index.search(query, params)
  end

  # search the results through all the pages
  def retrieve_all(params = {})
    search(
      '',
      params.merge(
        hitsPerPage: UpdaterHelper::NUMBER_OF_PRODUCTS_TO_ORDER
      )
    ).dig('hits')
  end

  private

  def init_client
    Algolia.init(application_id: @application_id, api_key: @api_key)
  end
end
