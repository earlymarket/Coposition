class RenameDeviceDeveloperPrivilegesToPermissions < ActiveRecord::Migration
  def change
    rename_table :device_developer_privileges, :permissions
  end
end
