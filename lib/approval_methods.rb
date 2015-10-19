module ApprovalMethods

  def pending_approvals
    approvals.where(pending: true)
  end
  
  def approval_status_for(model)
    app = approvals.where({ model.class.to_s.downcase.to_sym => model }).first
    app.approved? if app
  end
  
end