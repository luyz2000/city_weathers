module Openweather
  class RequestWeather < ApplicationService
    attr_accessor :latitude, :longitude, :response, :parsed_response

    REQUEST_URL = 'https://api.openweathermap.org/data/2.5/onecall?'

    def initialize(latitude, longitude)
      @latitude = latitude
      @longitude = longitude
    end

    def call
      response = Faraday.get(REQUEST_URL + build_params, headers: { 'Content-Type' => 'application/json' })

      if response.status == 200
        @parsed_response = JSON.parse(response.body)
        success_response(only_temps)
      else
        error_response(response.body)
      end
    rescue StandardError => e
      error_response(e.message)
    end

    private

    def build_params
      excludes = '&exclude=current,minutely,hourly,alerts'
      units = '&units=metric'
      ['lat=', latitude, '&lon=', longitude, '&lang=es', '&appid=', ENV['OPENWEATHER_KEY'], excludes, units].join
    end

    def only_temps
      parsed_response["daily"].map do |weather|
        {
          date: Time.at(weather["dt"]).to_date,
          minimum_temperature: "#{weather["temp"]["min"]} Celsius",
          maximum_temperature: "#{weather["temp"]["max"]} Celsius"
        }
      end
    end

  end
end
