class ChangeAddressDefaultInCheckins < ActiveRecord::Migration
  def change
    change_column :checkins, :address, :string, default: 'No address available'
  end
end
