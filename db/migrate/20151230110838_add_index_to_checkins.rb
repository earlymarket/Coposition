class AddIndexToCheckins < ActiveRecord::Migration
  def change
    add_index :checkins, :device_id
  end
end
