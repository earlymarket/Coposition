module Users::Approvals
  class DestroyApproval
    include Interactor

    delegate :current_user, :params, to: :context

    def call
      context.fail! unless approval
      revoke ? revoke_approval : destroy_approval
      context.approvable_type = approvable_type
    end

    private

    def revoke_approval
      destroy_access_tokens
      approval.update(status: "accepted")
    end

    def destroy_approval
      current_user.destroy_permissions_for(approvable)
      destroy_friend_side if approvable_type == "User"
      create_destroy_activity
      approval.destroy
    end

    def create_destroy_activity
      CreateActivity.call(entity: approval,
                          action: :destroy,
                          owner: current_user,
                          params: { approvable: approvable.email })
    end

    def destroy_access_tokens
      application = approvable.oauth_application
      Doorkeeper::AccessToken.where(application_id: application.id, resource_owner_id: current_user.id).destroy_all
    end

    def destroy_friend_side
      approvable.destroy_permissions_for(current_user)
      Approval.where(user: approvable, approvable: current_user, approvable_type: "User").destroy_all
    end

    def approval
      @approval ||= Approval.find_by(id: params[:id], user: current_user)
    end

    def revoke
      @revoke ||= params[:revoke]
    end

    def approvable_type
      @approvable_type ||= approval.approvable_type
    end

    def approvable
      @approvable ||= approval.approvable
    end
  end
end
