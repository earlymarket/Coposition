class AddCloakedToDevices < ActiveRecord::Migration[5.0]
  def change
  	add_column :devices, :cloaked, :boolean, default: false
  end
end
