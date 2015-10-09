class AddCityPostalCodeCountryCodeToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :city, :string
    add_column :checkins, :postal_code, :string
    add_column :checkins, :country, :string
  end
end
