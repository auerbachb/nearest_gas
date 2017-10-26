Rails.application.routes.draw do
  get 'nearest_gas', to: 'locations#nearest_gas', format: 'json'
end
