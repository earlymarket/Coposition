module Users::Approvals
  class RejectApproval
    include Interactor

    delegate :current_user, :params, to: :context

    def call
      current_user.destroy_permissions_for(approvable)
      if approvable_type == 'User'
        approvable.destroy_permissions_for(current_user)
        Approval.where(user: approvable, approvable: current_user, approvable_type: 'User').destroy_all
      end
      approval.destroy
      context.approvable_type = approvable_type
    end

    private

    def approval
      @approval ||= Approval.find_by(id: params[:id], user: current_user)
    end

    def approvable_type
      @approvalble_type ||= approval.approvable_type
    end

    def approvable
      @approvable ||= approval.approvable
    end
  end
end
