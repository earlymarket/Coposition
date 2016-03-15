class RemoveShowHistoryFromPermissions < ActiveRecord::Migration
  def change
    remove_column :permissions, :show_history, :boolean
  end
end
