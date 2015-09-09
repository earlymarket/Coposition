class AddImeiToCheckin < ActiveRecord::Migration
  def change
    add_column :checkins, :imei, :string
  end
end
