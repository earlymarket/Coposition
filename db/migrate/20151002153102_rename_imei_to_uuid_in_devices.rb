class RenameImeiToUuidInDevices < ActiveRecord::Migration
  def change
  	rename_column :devices, :imei, :uuid
  end
end
