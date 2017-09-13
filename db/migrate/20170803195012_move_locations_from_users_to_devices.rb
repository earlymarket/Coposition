class MoveLocationsFromUsersToDevices < ActiveRecord::Migration[5.0]
  def change
    remove_column :locations, :user_id
    add_column :locations, :device_id, :integer, index: true

    change_column :checkins, :location_id, :integer, index: true
  end
end
