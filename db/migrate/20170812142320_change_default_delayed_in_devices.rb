class ChangeDefaultDelayedInDevices < ActiveRecord::Migration[5.0]
  def change
    change_column :devices, :delayed, :integer, default: 0
  end
end
