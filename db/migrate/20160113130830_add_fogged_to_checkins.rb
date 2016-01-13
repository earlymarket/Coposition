class AddFoggedToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :fogged, :boolean
  end
end
