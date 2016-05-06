class ChangeDefaultAddressInCheckins < ActiveRecord::Migration
  def change
    change_column :checkins, :address, :string, default: 'Not yet geocoded'
  end
end

