module Users::Approvals
  class RejectApproval
    include Interactor

    delegate :current_user, :params, to: :context

    def call
      context.fail! unless approval
      current_user.destroy_permissions_for(approvable)
      destroy_friend_side if approvable_type == 'User'
      approval.destroy
      context.approvable_type = approvable_type
    end

    private

    def destroy_friend_side
      approvable.destroy_permissions_for(current_user)
      Approval.where(user: approvable, approvable: current_user, approvable_type: 'User').destroy_all
    end

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
