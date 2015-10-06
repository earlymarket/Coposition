module ApprovalMethods

  def pending_approvals
    approvals.where(pending: true)
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
    app.pending = false
    app.save
  end

  def approved_developer?(dev)
    app = approvals.where(developer: dev).first
    app && app.approved?
  end

end