# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoviesClient do
  describe '#search' do
    let(:query) { 'Something' }
    let(:page) { 3 }
    let(:movies_client) { described_class.new(:Movie, query:, page:, api_key:) }
    let(:result) { movies_client.search }

    before do
      allow(ApiCallingConfiguration.instance).to receive(:movies_client_api_key).and_return(api_key)
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

    context 'when the request execution is not succeeded due to an authentication problem then' do
      let(:api_key) { '---a-wrong-api-key---' }
      let(:response_code) { 401 }
      let(:response_body) do
        File.read(Rails.root.join('spec/support/examples/movies_client/search_with_wrong_api_key.txt'))
      end
      let(:expected_result) do
        {
          code: response_code,
          response: {
            'status_code' => 7,
            'status_message' => 'Invalid API key: You must be granted a valid key.',
            'success' => false
          }
        }
      end

      it 'provides the preprocessed response data' do
        expect(result).to eq(expected_result)
      end
    end

    context 'when the request execution is not succeeded due to a general network issue then' do
      let(:api_key) { '---a-correct-api-key---' }
      let(:response_code) { 200 }
      let(:response_body) { '' }
      let(:request) { instance_double(RestClient::Request) }
      let(:error_message) { 'There is a seriously complex problem' }
      let(:expected_result) { { error: { class: 'SocketError', message: error_message } } }

      before do
        allow(RestClient::Request).to receive(:new).and_return(request)
        allow(request).to receive(:execute).and_raise(SocketError.new(error_message))
      end

      it 'provides information about the issue' do
        expect(result).to eq(expected_result)
      end
    end

    context 'when the request execution is succeeded then' do
      let(:api_key) { '---a-correct-api-key---' }
      let(:response_code) { 200 }
      let(:response_body) do
        File.read(Rails.root.join('spec/support/examples/movies_client/search_with_correct_api_key.txt'))
      end
      let(:expected_result) do
        {
          code: response_code,
          response: {
            'page' => 1,
            'results' => [
              {
                'adult' => false,
                'backdrop_path' => nil,
                'genre_ids' => [16, 28, 12],
                'id' => 184_902,
                'original_language' => 'en',
                'original_title' => 'Something',
                'overview' => 'Something happened ...',
                'popularity' => 4.717,
                'poster_path' => '/a-relevant-path.jpg',
                'release_date' => '2012-09-11',
                'title' => 'Something',
                'video' => true,
                'vote_average' => 7.4,
                'vote_count' => 22
              },
              {
                'adult' => false,
                'backdrop_path' => nil,
                'genre_ids' => [16, 28, 12],
                'id' => 184_903,
                'original_language' => 'en',
                'original_title' => 'Something 2',
                'overview' => 'Something happened again ...',
                'popularity' => 4.717,
                'poster_path' => nil,
                'release_date' => '2013-10-11',
                'title' => 'Something',
                'video' => true,
                'vote_average' => 7.5,
                'vote_count' => 22
              }
            ],
            'total_pages' => 8,
            'total_results' => 151
          }
        }
      end

      it 'provides the preprocessed response data' do
        expect(result).to eq(expected_result)
      end
    end
  end
end
