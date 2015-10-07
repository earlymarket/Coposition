class AddPendingToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :pending, :boolean, default: true
  end
end
