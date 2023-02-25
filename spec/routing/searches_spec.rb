# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :routing do
  describe '(ROUTING)' do
    describe 'GET /movie-search' do
      subject { { get: movie_search_path } }

      it { is_expected.to eq({ get: '/movie-search' }) }
      it { is_expected.to route_to(controller: 'searches', action: 'search', class_name: 'Search::Movie') }
    end
  end
end
