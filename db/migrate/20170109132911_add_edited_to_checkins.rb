class AddEditedToCheckins < ActiveRecord::Migration[5.0]
  def change
    add_column :checkins, :edited, :boolean, default: false
  end
end
