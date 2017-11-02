class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.decimal :lat, null: false, precision: 10, scale: 6
      t.decimal :lng, null: false, precision: 10, scale: 6

      t.string  :street_address, null: false
      t.string  :city, null: false
      t.string  :state, null: false
      t.string  :postal_code, null: false
      t.boolean :gas, default: false
      t.references :location, foreign_key: true
      t.timestamps
    end
  end
end
