class RemoveIndexOnPermissibleIdAndDeviceIdFromPermissions < ActiveRecord::Migration
  def change
    remove_index :permissions, [:permissible_id, :device_id]
  end
end
