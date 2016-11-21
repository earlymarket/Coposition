class ChangeDefaultFoggedInDevices < ActiveRecord::Migration[5.0]
  def change
    change_column_default :devices, :fogged, from: false, to: true
  end
end
