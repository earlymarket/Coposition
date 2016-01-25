class ChangeDeveloperIdInPermissions < ActiveRecord::Migration
  def change
    rename_column :permissions, :developer_id, :permissible_id
  end
end
