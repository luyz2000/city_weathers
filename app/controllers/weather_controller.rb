class WeatherController < ApplicationController
  def show
    request_places = Reservamos::RequestPlaces.new(params[:city_name]).call

    if request_places.success?
      response = get_places(request_places.data, type_temp: params[:type_temp])
      render(status: :ok, json: response)
    else
      render(status: :unprocessable_entity)
    end
  end

  def recomended_city
    request_places = Reservamos::RequestPlaces.new(params[:city_name]).call

    if request_places.success?
      response = get_places(request_places.data, type_temp: params[:type_temp])
      render(status: :ok, json: response)
    else
      render(status: :unprocessable_entity)
    end
  end

  private

  def get_places(places, type_temp)
    collection =
      places.map do |city|
        request_weather = Openweather::RequestWeather.new(city.lat, city.long, type_temp).call
        next unless request_weather.success?

        build_city_weather(city, request_weather.data)
      end

    collection.compact!
    collection = collection.uniq
    type_temp == 'all' ? type_temp : collection.sort_by{|city| city[:weather].to_i }.last
  end

  def build_city_weather(city, weather_data)
    {
      state: city.state,
      city: city.city_name,
      weather: weather_data
    }
  end
end
