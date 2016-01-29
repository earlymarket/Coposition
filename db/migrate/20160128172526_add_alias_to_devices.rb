class AddAliasToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :alias, :string
  end
end
