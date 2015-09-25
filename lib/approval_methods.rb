module ApprovalMethods

  def pending_approvals
    approvals.where(approved: false)
  end

  def approved_users
    approvals.where(approved: true)
  end

  def approved_developers
    approvals.where(approved: true)
  end

  def request_approval_from(user)
    approvals << Approval.create(user: user)
  end

  def approve_developer(dev)
    app = approvals.where(approved: false, developer: dev).first
    app.approved = true
    app.save
  end

end