module Users::Approvals
  class CreateDeveloperApproval
    include Interactor

    delegate :current_user, :approvable, to: :context

    def call
      context.developer = developer
      context.approval = approval
      return if developer && approval.save
      context.fail!(error: approval ? approval.errors[:base].first : "Developer not found")
    end

    private

    def developer
      @developer ||= Developer.find_by(company_name: approvable)
    end

    def approval
      @approval ||= Approval.add_developer(current_user, developer) if developer
    end
  end
end
