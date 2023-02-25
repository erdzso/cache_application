# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiCallingConfiguration do
  let(:instance) { described_class.instance }

  before do
    instance.reset
  end

  describe '#expiration_time' do
    before do
      allow(instance).to receive(:configuration).and_return(configuration)
    end

    context 'when expiration time was set previously then' do
      let(:expiration_time) { 112 }
      let(:configuration) { { expiration_time: } }

      it 'returns with the set value' do
        expect(instance.expiration_time).to eq(expiration_time)
      end
    end

    context 'when expiration time was not set previously then' do
      let(:expiration_time) { 120 }
      let(:configuration) { {} }

      it 'returns with the default value' do
        expect(instance.expiration_time).to eq(expiration_time)
      end
    end
  end

  describe '#movies_client_api_key' do
    let(:movies_client_api_key) { '---a-real-api-key---' }
    let(:configuration) { { movies_client_api_key: } }

    before do
      allow(instance).to receive(:configuration).and_return(configuration)
    end

    it 'returns with the set value' do
      expect(instance.movies_client_api_key).to eq(movies_client_api_key)
    end
  end

  describe '#configuration' do
    let(:yaml_configuration) { "---\n:test: Test\n" }
    let(:configuration) { { test: 'Test' } }

    before do
      allow(File).to receive(:read).and_return(yaml_configuration)
    end

    it 'reads the configuration from file' do
      expect(instance.configuration).to eq(configuration)
    end
  end
end
