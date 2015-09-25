module ApprovalMethods

  def pending_approvals
    approvals.where(approved: false)
  end

  def approved_users
    approvals.where(approved: true)
  end

  def request_approval_from(model)
    approvals << Approval.create(model.class.to_s.downcase.to_sym => model)
  end

end