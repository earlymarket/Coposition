class ChangeDeveloperIdInApprovals < ActiveRecord::Migration
  def change
    rename_column :approvals, :developer_id, :approvable_id
  end
end
