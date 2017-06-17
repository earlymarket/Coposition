class AddColumnCheckinsCountToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :checkins_count, :integer
  end
end
