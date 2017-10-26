json.address do
  json.streetAddress @address.street_address
  json.city @address.city
  json.state @address.state
  json.postalCode @address.postal_code
end

json.nearest_gas_station do
  json.streetAddress @nearest_gas_station.street_address
  json.city @nearest_gas_station.city
  json.state @nearest_gas_station.state
  json.postalCode @nearest_gas_station.postal_code
end