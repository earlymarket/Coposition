class AddAddressToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :address, :string
  end
end
