class AddAssociationsForLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :user_id, :integer
    add_column :checkins, :location_id, :integer
  end
end
