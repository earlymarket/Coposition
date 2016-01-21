class RemoveApprovedAndPendingFromApprovals < ActiveRecord::Migration
  def change
    remove_column :approvals, :approved, :boolean
    remove_column :approvals, :pending, :boolean
  end
end
