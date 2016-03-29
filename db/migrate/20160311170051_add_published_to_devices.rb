class AddPublishedToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :published, :boolean, default: false
  end
end
