module ApprovalMethods

  def pending_approvals
    approvals.where(status: 'developer-requested')
  end

  def approval_status_for(resource)
    model = resource.class.to_s.downcase.to_sym
    if model == :developer
      app = approvals.where(approvable_id: resource.id, approvable_type: 'Developer').first
    else
      app = approvals.where(approvable_id: resource.id, approvable_type: 'User').first
    end
    app.status if app
  end

end
