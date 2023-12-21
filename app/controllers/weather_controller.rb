class WeatherController < ApplicationController
  before_action :set_places, only: [:show]
  before_action :set_places_from, only: [:recomended_city, :best_day_to_travel]

  def show
    @request_places = Reservamos::RequestPlaces.new(params[:city_name]).call
    if @request_places.success?
      response = get_places(@request_places.data, 'all')
      render(status: :ok, json: response)
    else
      render(status: :unprocessable_entity)
    end
  end

  def recomended_city
    if @request_places.success?
      response = get_places(@request_places.data, 'best_temp')
      render(status: :ok, json: response)
    else
      render(status: :unprocessable_entity)
    end
  end

  def best_day_to_travel
    if @request_places.success?
      response = get_places(@request_places.data, 'best_temp_and_humidity')
      render(status: :ok, json: response)
    else
      render(status: :unprocessable_entity)
    end
  end

  private

  def set_places
    @request_places = Reservamos::RequestPlaces.new(params[:city_name]).call
  end

  def set_places_from
    @request_places = Reservamos::RequestPlacesFrom.new(params[:city_name]).call
  end

  def get_places(places, type_temp)
    collection =
      places.map do |city|
        request_weather = Openweather::RequestWeather.new(city.lat, city.long, type_temp).call
        next unless request_weather.success?

        build_city_weather(city, request_weather.data)
      end

    collection.compact!
    collection = collection.uniq
    type_temp == 'best_temp' ? collection.sort_by{|city| city[:weather].to_i }.last : collection
  end

  def build_city_weather(city, weather_data)
    {
      state: city.state,
      city: city.city_name,
      weather: weather_data
    }
  end
end
