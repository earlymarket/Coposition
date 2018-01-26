class CreateApproval
  include Interactor

  delegate :user, :approvable, :type, to: :context

  def call
    if type == "Developer"
      create_user_developer_approval
    elsif friend && user.request_from?(friend)
      context.approval = Approval.accept(user, friend, "User")
    else
      create_user_approval
    end
  end

  def create_user_approval
    result = Users::Approvals::CreateUserApproval.call(current_user: user, approvable: approvable)
    context.fail! unless result.success?
    context.approval = result.approval
  end

  def create_user_developer_approval
    result = Users::Approvals::CreateDeveloperApproval.call(current_user: user, approvable: approvable)
    context.fail! unless result.success?
    context.approval = result.approval
  end

  def friend
    @friend ||= User.find_by(email: approvable)
  end
end
