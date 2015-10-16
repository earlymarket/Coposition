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
    Approval.create(developer: self, user: user)
  end

  def approve_developer(dev)
    app = approvals.where(approved: false, developer: dev).first
    unless app
      return false
    end
    app.approved = true
    app.pending = false
    app.save
  end

  def approved_developer?(dev)
    app = approvals.where(developer: dev).first
    app && app.approved?
  end

  def approval_status_for(model)
    app = approvals.where({ model.class.to_s.downcase.to_sym => model }).first
    app.approved? if app
  end

end