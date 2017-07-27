class AddSpeedAndAltitudeToCheckins < ActiveRecord::Migration[5.0]
  def change
    add_column :checkins, :speed, :integer
    add_column :checkins, :altitude, :integer
  end
end
