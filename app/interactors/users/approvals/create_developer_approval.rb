module Users::Approvals
  class CreateDeveloperApproval
    include Interactor

    delegate :current_user, :approvable, to: :context

    def call
      context.developer = developer
      context.approval = approval
      if developer && approval.save
        create_activity
      else
        context.fail!(error: approval_create_error)
      end
    end

    private

    def create_activity
      CreateActivity.call(entity: approval, action: :create, owner: current_user, params: { approvable: approvable })
    end

    def approval_create_error
      approval ? approval.errors[:base].first : "Developer not found"
    end

    def developer
      @developer ||= Developer.find_by(company_name: approvable)
    end

    def approval
      @approval ||= Approval.add_developer(current_user, developer) if developer
    end
  end
end
