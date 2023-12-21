module Openweather
  class RequestWeather < ApplicationService
    attr_accessor :latitude, :longitude, :response, :type_temp, :parsed_response

    REQUEST_URL = 'https://api.openweathermap.org/data/2.5/onecall?'

    def initialize(latitude, longitude, type_temp = 'all')
      @latitude = latitude
      @longitude = longitude
      @type_temp = type_temp
    end

    def call
      response = Faraday.get(REQUEST_URL + build_params, headers: { 'Content-Type' => 'application/json' })

      if response.status == 200
        @parsed_response = JSON.parse(response.body)
        case @type_temp
          when 'all'
            success_response(only_temps)
          when 'best_temp_and_humidity'
            success_response(best_temps_humidity)
          when 'best_temp'
            success_response(high_temp)
        end
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

    def high_temp
      all_temps = parsed_response["daily"].map{ |weather| weather["temp"]["max"] }
      [(all_temps.sum / all_temps.size).round, ' Celsius'].join
    end

    def best_temps_humidity
      collection = parsed_response["daily"].map do |weather|
        {
          date: Time.at(weather["dt"]).to_date,
          maximum_temperature: "#{weather["temp"]["max"]} Celsius",
          humidity: weather["humidity"]
        }
      end
      collection.sort_by{|weather| weather[:humidity] }.last
    end

  end
end
