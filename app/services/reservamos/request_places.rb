module Reservamos
  class RequestPlaces < ApplicationService
    attr_accessor :place, :response, :parsed_response

    REQUEST_URL = 'https://search.reservamos.mx/api/v2/places?q='

    def initialize(place)
      @place = place.strip
    end

    def call
      response = Faraday.get(REQUEST_URL + @place, headers: { 'Content-Type' => 'application/json' })

      if response.status == 201
        @parsed_response = JSON.parse(response.body, object_class: OpenStruct)
        success_response(only_cities)
      else
        error_response(response.body)
      end
    rescue StandardError => e
      error_response(e.message)
    end

    private

    def only_cities
      parsed_response.select { |city| city.result_type == 'city' }
    end
  end
end
