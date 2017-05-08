module Developers::Approvals
  class CreateApproval
    include Interactor

    delegate :developer, :params, to: :context

    def call
      if user && approval.id
        context.notice = "Successfully sent"
        context.approval = approval
        CreateActivity.call(entity: approval, action: :create, owner: developer, params: params.to_h)
      else
        context.fail!(alert: alert)
      end
    end

    private

    def alert
      user ? "Approval already exists" : "User does not exist"
    end

    def user
      @user ||= User.find_by(email: params[:user])
    end

    def approval
      @approval ||= Approval.link(user, developer, "Developer")
    end
  end
end
