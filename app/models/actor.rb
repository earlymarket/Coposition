class Actor < ActiveRecord::Base
 
  def pending_approvals
    approvals.where(approved: false)
  end

  def approved_relationships
    approvals.where(approved: true)
  end


end
