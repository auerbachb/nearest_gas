# spec/factories/locations.rb
require 'faker'

FactoryBot.define do
  factory :location do
    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.postcode}
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
  end
end