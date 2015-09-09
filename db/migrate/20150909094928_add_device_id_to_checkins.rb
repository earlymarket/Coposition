class AddDeviceIdToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :device_id, :integer
  end
end
