class AddControlsToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :bypass_fogging, :boolean, default: false
    add_column :permissions, :show_history, :boolean, default: false
  end
end
