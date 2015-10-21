class CreateDeviceDeveloperPrivileges < ActiveRecord::Migration
  def change
    create_table :device_developer_privileges do |t|
      t.integer :developer_id
      t.integer :device_id
      t.integer :privilege
    end
  end
end
