class LocationsController < ApplicationController
  def nearest_gas
    lat = location_params[:lat]
    lng = location_params[:lng]
    @address = Location.find_or_create_location(lat, lng)
    @nearest_gas_station = @address.find_or_create_gas_station(lat, lng)
  end

  private

  def location_params
    params.permit(:lat, :lng)
  end
end
