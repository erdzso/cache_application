# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches (REQUESTS)', type: :request do
  describe 'GET /movie-search' do
    let(:api_key) { '---a-correct-api-key---' }
    let(:query) { 'asdf' }
    let(:page) { 1 }
    let(:params) { { query: } }
    let(:response_code) { 200 }
    let(:response_body) do
      File.read(Rails.root.join('spec/support/examples/movies_client/search_with_correct_api_key.txt'))
    end
    let(:time) { Time.zone.now.round }
    let(:expiration_time) { 120 }

    before do
      allow(ApiCallingConfiguration.instance).to receive(:movies_client_api_key).and_return(api_key)
      allow(ApiCallingConfiguration.instance).to receive(:expiration_time).and_return(expiration_time)
      stub_request(:get, "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&page=#{page}&query=#{query}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'api.themoviedb.org',
            'User-Agent' => 'rest-client/2.1.0 (linux x86_64) ruby/3.2.0p0'
          }
        )
        .to_return(status: response_code, body: response_body, headers: {})
    end

    context 'when there was no identical search request then' do
      before do
        Timecop.freeze time do
          get(movie_search_path, params:)
        end
      end

      it 'creates a Search::Movie instance with the related ApiCalling instance' do
        search = Search::Movie.first
        expect(search.query).to eq(query)
        expect(search.page).to eq(page)

        api_calling = search.api_callings.last
        expect(api_calling).to be_a(ApiCalling)
        expect(api_calling).to be_succeeded
        expect(api_calling.expired_at).to eq(time + expiration_time.seconds)
        expect(api_calling.hit_count).to eq(0)
      end

      it 'informs that the results were provided from an API request' do
        expect(response.body).to include('Results were provided from an API request')
      end
    end

    context 'when there was no identical search request but simultaneously one is created then' do
      before do
        previously_called = false
        original_method = Search::Movie.method(:find_or_initialize_by)
        allow(Search::Movie).to receive(:find_or_initialize_by) do |params|
          movie_search = original_method.call(params)
          unless previously_called
            Search::Movie.new(params).process!
            previously_called = true
          end
          movie_search
        end
      end

      it 'increases the hit_count of the appropriate ApiCalling instance' do
        expect(Search::Movie).to receive(:find_or_initialize_by).with(query:, page:).twice

        Timecop.freeze time do
          get(movie_search_path, params:)
        end

        search = Search::Movie.first
        expect(search.query).to eq(query)
        expect(search.page).to eq(page)

        api_calling = search.api_callings.last
        expect(api_calling).to be_a(ApiCalling)
        expect(api_calling).to be_succeeded
        expect(api_calling.expired_at).to eq(time + expiration_time.seconds)
        expect(api_calling.hit_count).to eq(1)
      end

      it 'informs that the results were provided from cache and shows the correct hit count' do
        Timecop.freeze time do
          get(movie_search_path, params:)
        end

        expect(response.body).to include('Results were provided from cache (hit count: 1)')
      end
    end

    context 'when there was no identical search request in previous 2 minutes but there was an earlier then' do
      let(:earlier) { Time.zone.now - 3.minutes }
      let(:search) { create(:movie_search, query:, page:) }

      before do
        Timecop.freeze earlier do
          search.process!
        end
        search.reload

        Timecop.freeze time do
          get(movie_search_path, params:)
        end
      end

      it 'identifies the Search::Movie instance and creates a new related ApiCalling instance' do
        expect(search.api_callings.count).to eq(2)

        api_calling = search.api_callings.last
        expect(api_calling).to be_a(ApiCalling)
        expect(api_calling).to be_succeeded
        expect(api_calling.expired_at).to eq(time + expiration_time.seconds)
        expect(api_calling.hit_count).to eq(0)
      end

      it 'informs that the results were provided from an API request' do
        expect(response.body).to include('Results were provided from an API request')
      end
    end

    context 'when there was identical search request in previous 2 minutes and it is executed then' do
      let(:now) { Time.zone.now.round }
      let(:earlier) { now - 1.minute }
      let(:expired_at) { now + 1.minute }
      let(:search) { create(:movie_search, query:, page:) }

      before do
        Timecop.freeze earlier do
          search.process!
        end
        search.reload

        get(movie_search_path, params:)
      end

      it 'increases the hit_count of the appropriate ApiCalling instance' do
        expect(search.api_callings.count).to eq(1)

        api_calling = search.api_callings.last
        expect(api_calling).to be_a(ApiCalling)
        expect(api_calling).to be_succeeded
        expect(api_calling.expired_at).to eq(expired_at)
        expect(api_calling.hit_count).to eq(1)
      end

      it 'informs that the results were provided from cache and shows the correct hit count' do
        expect(response.body).to include('Results were provided from cache (hit count: 1)')
      end
    end

    context 'when page parameter is wrong then' do
      let(:page) { 1001 }
      let(:params) { { query:, page: } }

      before do
        get(movie_search_path, params:)
      end

      it 'handles error and shows information about it' do
        expect(response.body).to include('Validation failed: Page must be less than or equal to 1000')
      end

      it 'does not shows information about results' do
        expect(response.body).not_to include('Results were provided from')
      end
    end

    context 'when the API is unreachable due to a general network issue then' do
      let(:request) { instance_double(RestClient::Request) }

      before do
        allow(RestClient::Request).to receive(:new).and_return(request)
        allow(request).to receive(:execute).and_raise(SocketError.new('There is a seriously complex problem'))
        get(movie_search_path, params:)
      end

      it 'provides information about the issue' do
        expect(response.body).to include('Could not reach the API')
      end
    end

    # context 'when there was identical search request in previous 2 minutes and it is not executed then' do
    #   let(:now) { Time.zone.now.round }
    #   let(:earlier) { now - 1.minute }
    #   let(:expired_at) { now + 1.minute }
    #   let(:search) { create(:movie_search, query:, page:) }

    #   before do
    #     Timecop.freeze earlier do
    #       search.process!
    #     end
    #     search.reload
    #   end

    #   it 'increases the hit_count of the appropriate ApiCalling instance' do
    #     get(movie_search_path, params:)

    #     expect(search.api_callings.count).to eq(1)

    #     api_calling = search.api_callings.last
    #     expect(api_calling).to be_a(ApiCalling)
    #     expect(api_calling).to be_created
    #     expect(api_calling.expired_at).to be_nil
    #     expect(api_calling.hit_count).to eq(1)
    #   end
    # end
  end
end
