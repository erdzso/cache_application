# frozen_string_literal: true

##
# This class responsible to process movies list
class MoviesClient
  def initialize(target, params = {})
    @target = target
    @url = "https://api.themoviedb.org/3#{path}"
    @params = params.merge(api_key: ApiCallingConfiguration.instance.movies_client_api_key)
  end

  class << self
    def mapping
      {
        Movie: { path: '/search/movie' }
      }
    end
  end

  def path
    send(:class).mapping[@target][:path]
  end

  def search
    request = RestClient::Request.new(method: :get, url: @url, headers: { params: @params })
    response = request.execute { |resp| resp }
    { code: response.code, response: JSON.parse(response) }
  rescue StandardError => e
    { error: { class: e.class.name, message: e.message } }
  end
end
