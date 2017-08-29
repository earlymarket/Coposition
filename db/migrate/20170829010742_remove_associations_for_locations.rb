class RemoveAssociationsForLocations < ActiveRecord::Migration[5.0]
  def change
    remove_column :locations, :device_id, :integer
    remove_column :checkins, :location_id, :integer
  end
end
