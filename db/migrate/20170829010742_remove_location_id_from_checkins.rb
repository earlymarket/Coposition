class RemoveLocationIdFromCheckins < ActiveRecord::Migration[5.0]
  def change
    remove_column :checkins, :location_id, :integer
  end
end
