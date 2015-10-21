class CreateDeviceApprovedDevelopers < ActiveRecord::Migration
  def change
    create_table :device_approved_developers do |t|
      t.integer :developer_id
      t.integer :device_id
    end
  end
end
