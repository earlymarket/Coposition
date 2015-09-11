class AddIndexToDevicesImei < ActiveRecord::Migration
  def change
    add_index(:devices, :imei)
  end
end
