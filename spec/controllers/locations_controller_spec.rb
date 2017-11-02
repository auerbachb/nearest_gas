require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  before do
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

  describe 'nearest_gas' do
    it 'responds to valid lat/lng with 200' do
      get :nearest_gas, params: { lat: '37.77802', lng: '-122.4119', format: :json }
      expect(response.content_type).to eq "application/json"
      expect(response.response_code).to eq 200
    end
  end
end
