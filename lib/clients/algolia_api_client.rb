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
  def retrieve_all(params = {}) # rubocop:disable Metrics/MethodLength
    page = 0
    all_hits = []
    search_results = search('', params.merge(page: page, hitsPerPage: 1000))
    all_hits += search_results['hits']
    number_of_pages = search_results['nbPages']

    # `page` is zero-based so we add 1 to page
    while (page + 1) < number_of_pages
      page += 1
      search_results = search('', params.merge(page: page, hitsPerPage: 1000))
      all_hits += search_results['hits']
    end
    all_hits
  end

  private

  def init_client
    Algolia.init(application_id: @application_id, api_key: @api_key)
  end
end
