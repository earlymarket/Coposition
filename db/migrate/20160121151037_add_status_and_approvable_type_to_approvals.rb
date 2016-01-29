class AddStatusAndApprovableTypeToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :status, :string
    add_column :approvals, :approvable_type, :string
  end
end
