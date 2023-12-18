
require 'rails_helper'

RSpec.describe 'Weather', type: :request do
  describe 'Api Key for Openweather' do
    let(:api_key) { ENV['OPENWEATHER_KEY'] }

    it 'check if is present' do
      expect(api_key.present?).to be_truthy
    end
  end

  describe 'GET /weather/:city_name' do
    before do
      get weather_path("nayarit")
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end

    it 'returns sigle result' do
      expect(json.size).to eq(1)
    end

  end
end
