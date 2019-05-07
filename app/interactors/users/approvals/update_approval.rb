module Users::Approvals
  class UpdateApproval
    include Interactor

    delegate :current_user, :params, to: :context

    def call
      context.fail! unless approval
      Approval.accept(current_user, approvable, approvable_type)
      create_activity
      context.approval = approval
      context.approvable_type = approvable_type
      context.approvable = approvable
    end

    private

    def create_activity
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      CreateActivity.call(entity: approval, action: :update, owner: current_user, params: params)
    end

    def approval
      @approval ||= Approval.find_by(id: params[:id], user: current_user)
    end

    def approvable_type
      @approvable_type ||= approval.approvable_type
    end

    def approvable
      @approvable ||= approval.approvable
    end
  end
end
