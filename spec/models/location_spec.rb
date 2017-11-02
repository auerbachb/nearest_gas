require 'rails_helper'

RSpec.describe Location, type: :model do
  before do
    @fake_location = FactoryBot.create(:location)

    @real_location = Location.create(
      street_address: '1155 Mission Street',
      city: 'San Francisco',
      state: 'CA',
      postal_code: '94103-1514',
      lat: '37.77802',
      lng: '-122.4119'
    )

    @real_gas = Location.create(
      street_address: '1298 Howard Street',
      city: 'San Francisco',
      state: 'CA',
      postal_code: '94103-2712',
      lat: '0.37775313e2',
      lng: '-0.122413152e3',
      gas: true
    )

    @real_location.gas_station = @real_gas
    @real_gas.gas_station = @real_gas
    @lat = @real_location.lat
    @lng = @real_location.lng
    @fake_lat = @fake_location.lat
    @fake_lng = @fake_location.lng

    geocode_res = { results: [
        address_components: [
            { long_name: Faker::Address.building_number, types: ['street_number'] },
            { long_name: Faker::Address.street_name, types: ['route'] },
            { long_name: Faker::Address.city, types: ['locality'] },
            { short_name: Faker::Address.state_abbr, types: ['administrative_area_level_1'] },
            { long_name: Faker::Address.zip[0...5], types: ['postal_code'] },
            { long_name: Faker::Address.zip[0...4], types: ['postal_code_suffix'] }
        ]
    ]}.to_json

    places_res = {
        results: [
            geometry: {
                location: {
                    lat: Faker::Address.latitude,
                    lng: Faker::Address.longitude
                }
            }
        ]
    }.to_json
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/geocode*/).to_return(:body => geocode_res, :status => 200, :headers => {})
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/place\/nearbysearch*/).to_return(:body => places_res, :status => 200, :headers => {})
  end

  describe 'Valid fields for creation' do
    it 'can be created if valid' do
      expect(@real_location).to be_valid
    end

    it 'will not be created if not valid' do
      @real_location.street_address = nil
      expect(@real_location).to_not be_valid
    end
  end

  describe 'find_or_create_location' do
    it 'should find existing location' do
      Location.find_or_create_location(@lat, @lng).equal? @real_location
    end

    it 'should find existing location up to 4 decimal places' do
      new_lat = @lat.to_f + 0.000004
      new_lng = @lng.to_f + 0.000005
      Location.find_or_create_location(new_lat.to_s, new_lng.to_s).equal? @real_location
    end

    it 'should create location if it does not exist yet' do
      new_lat = (@lat.to_f + 0.004).to_s
      new_lng = (@lng.to_f + 0.004).to_s
      old_size = Location.all.size

      Location.find_or_create_location(new_lat, new_lng)
      old_size.equal?(Location.all.size - 1)
    end
  end

  describe 'find_or_create_gas_station' do

    it 'should find existing gas station' do
      @real_location.find_or_create_gas_station(@lat, @lng).equal? @real_gas
    end

    it 'should find existing gas station up to 4 decimal places' do
      new_lat = @lat.to_f + 0.00004
      new_lng = @lng.to_f + 0.00004
      @real_location.find_or_create_gas_station(new_lat.to_s, new_lng.to_s).equal? @real_location
    end

    it 'should create a new gas station if it does not exist yet' do
      new_lat = (@lat.to_f + 0.004).to_s
      new_lng = (@lng.to_f + 0.004).to_s
      old_size = Location.all.size

      @real_location.find_or_create_gas_station(new_lat, new_lng)
      old_size.equal?(Location.all.size - 1)
    end

    it 'should update nearest gas station if station is stale' do
      @real_gas.updated_at -= 2.weeks
      @real_location.find_or_create_gas_station(@lat, @lng).equal? @real_location
      Date.today.equal? @real_gas.updated_at
    end

    it 'should not update gas station if not stale' do
      @real_gas.updated_at -= 2.days
      @real_location.find_or_create_gas_station(@lat, @lng).equal? @real_location
      @real_gas.updated_at.equal? 2.days.ago
    end

    it 'should return itself if coordinates are for a gas station' do
      @real_gas.find_or_create_gas_station(@real_gas.lat, @real_gas.lng).equal? @real_gas
    end
  end
end
