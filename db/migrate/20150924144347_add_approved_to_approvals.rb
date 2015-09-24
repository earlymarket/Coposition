class AddApprovedToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :approved, :boolean
  end
end
