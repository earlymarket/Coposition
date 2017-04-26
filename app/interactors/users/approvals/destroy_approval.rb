module Users::Approvals
  class DestroyApproval
    include Interactor

    delegate :current_user, :params, to: :context

    def call
      context.fail! unless approval
      current_user.destroy_permissions_for(approvable)
      destroy_friend_side if approvable_type == "User"
      create_destroy_activity
      approval.destroy
      context.approvable_type = approvable_type
    end

    private

    def create_destroy_activity
      approval.create_activity :destroy, owner: current_user, parameters: { approvable: approvable.email }
    end

    def destroy_friend_side
      approvable.destroy_permissions_for(current_user)
      Approval.where(user: approvable, approvable: current_user, approvable_type: "User").destroy_all
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
