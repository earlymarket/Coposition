class RenameFoggedAreaToFoggedCityInCheckins < ActiveRecord::Migration[5.0]
  def change
    rename_column :checkins, :fogged_area, :fogged_city
  end
end
