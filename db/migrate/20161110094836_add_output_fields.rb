class AddOutputFields < ActiveRecord::Migration[5.0]
  def change
    add_column :checkins, :output_lat, :float
    add_column :checkins, :output_lng, :float
    add_column :checkins, :output_address, :string
    add_column :checkins, :output_city, :string
    add_column :checkins, :output_postal_code, :string
    add_column :checkins, :output_country_code, :string
  end
end
