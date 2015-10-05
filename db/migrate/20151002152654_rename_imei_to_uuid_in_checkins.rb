class RenameImeiToUuidInCheckins < ActiveRecord::Migration
  def change
  	rename_column :checkins, :imei, :uuid
  end
end
