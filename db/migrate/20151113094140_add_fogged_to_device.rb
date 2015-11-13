class AddFoggedToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :fogged, :boolean
  end
end
