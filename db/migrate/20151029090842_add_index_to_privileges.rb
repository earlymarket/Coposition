class AddIndexToPrivileges < ActiveRecord::Migration
  def change
    add_index :device_developer_privileges, [:developer_id, :device_id], :unique => true
  end
end
