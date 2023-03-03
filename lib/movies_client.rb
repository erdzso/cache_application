# frozen_string_literal: true

##
# This class responsible to process movies list
class MoviesClient
  def initialize(params = {})
    @url = 'https://api.themoviedb.org/3/search/movie'
    @params = params
  end

  def search
    request = RestClient::Request.new(method: :get, url: @url, headers: { params: @params })
    response = request.execute { |resp| resp }
    { code: response.code, response: JSON.parse(response) }
  end
end
