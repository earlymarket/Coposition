class AddIconToDevices < ActiveRecord::Migration[5.0]
  def change
  	add_column :checkins, :fogged_country_code, :string, default: 'devices_other'
  end
end
