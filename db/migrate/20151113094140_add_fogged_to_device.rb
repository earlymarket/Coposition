class AddFoggedToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :fogged, :boolean, default: false
  end
end
