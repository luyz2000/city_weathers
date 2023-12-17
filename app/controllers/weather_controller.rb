class WeatherController < ApplicationController
  def show
    request_places = Reservamos::RequestPlaces.new(params[:city_name]).call

    if request_places.success?
      response = get_places(request_places.data)
      render(status: :ok, json: response)
    else
      render(status: :unprocessable_entity)
    end
  end

  private

  def get_places(places)
    collection =
      places.map do |city|
        request_weather = Openweather::RequestWeather.new(city.lat, city.long).call
        next unless request_weather.success?

        build_city_weather(city, request_weather.data)
      end

    collection.compact!
    collection.uniq
  end

  def build_city_weather(city, weather_data)
    {
      state: city.state,
      city: city.city_name,
      weather: weather_data
    }
  end
end
