class AddFoggedAttributesToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :fogged_lat, :float
    add_column :checkins, :fogged_lng, :float
    add_column :checkins, :fogged_area, :string
  end
end
