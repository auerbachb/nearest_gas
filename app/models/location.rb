class Location < ApplicationRecord
  validates :lat, :lng, :street_address, :city, :state, :postal_code, presence: true
  attr_accessor :location_id

  def self.find_or_create_location(lat, lng)
    query = "SELECT * FROM locations WHERE lat like '#{lat.to_f.round(4)}%' and lng like '#{lng.to_f.round(4)}%'"
    location = Location.find_by_sql(query).first

    if location.nil?
      address_info = coordinates_to_address(lat, lng)
      address_info[:lat] = lat
      address_info[:lng] = lng
      location = Location.create!(address_info)
    end

    location
  end

  def find_or_create_gas_station(lat, lng)
    gas_station = self.gas_station
    if gas_station
      address_info = gas_station.stale? ? coordinates_to_address(lat, lng) : {}
      location = Location.update(address_info).first
    else
      gs_coords = gas_station_coordinates(lat, lng)
      location = Location.find_or_create_location(gs_coords['lat'], gs_coords['lng'])

      location.gas = true
    end

    self.gas_station = location
    location.gas_station = location

    location
  end

  def gas_station?
    gas
  end

  def gas_station=(location)
    self.update!(location_id: location.id)
  end

  def gas_station
    Location.find(self.location_id)
  rescue
    nil
  end

  def stale?
    self.updated_at + 1.week < DateTime.now
  end

  private

  def self.coordinates_to_address(lat, lng)
    components = select_components(reverse_geocode_api_call(lat, lng))
    {
        street_address: "#{components[0]} #{components[1]}",
        city: components[2],
        state: components[3],
        postal_code: "#{components[4]}-#{components[5]}"
    }
  end

  def self.select_components(components)
    fields = ['street_number', 'route', 'locality', 'administrative_area_level_1', 'postal_code', 'postal_code_suffix']
    components.select! { |component| fields.include? component['types'].first}
    components.map! { |component| component['types'].first == 'administrative_area_level_1' ? component['short_name'] : component['long_name'] }
  end

  def gas_station_coordinates(lat, lng)
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&type=gas_station&rankby=distance&key=#{Rails.application.secrets[:GOOGLE_PLACES_API_KEY]}"
    json = JSON.parse(RestClient.get(url))
    json['results'].any? ? json['results'].first['geometry']['location'] : raise(Exception.new('No gas stations found'))
  end

  def self.reverse_geocode_api_call(lat, lng)
    url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{Rails.application.secrets[:GOOGLE_GEOCODE_API_KEY]}"
    json = JSON.parse(RestClient.get(url))
    json['results'].any? ? json['results'].first['address_components'] : raise(Exception.new('No geocoded information found'))
  end
end
