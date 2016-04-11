class AddBypassDelayAndChangeShowHistoryDefaultInPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :bypass_delay, :boolean, default: false
    change_column :permissions, :show_history, :boolean, default: true
  end
end
