module ApprovalMethods
  def pending_approvals
    approvals.where(status: 'developer-requested')
  end
end
