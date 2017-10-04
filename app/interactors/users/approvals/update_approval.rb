module Users::Approvals
  class UpdateApproval
    include Interactor

    delegate :current_user, :params, to: :context

    def call
      context.fail! unless approval
      Approval.accept(current_user, approvable, approvable_type)
      create_activity
      notify_request_sender
      context.approval = approval
      context.approvable_type = approvable_type
      context.approvable = approvable
    end

    private

    def create_activity
      CreateActivity.call(entity: approval, action: :update, owner: current_user, params: params.to_h)
    end

    def notify_request_sender
      Firebase::Push.call(
        topic: approvable.id,
        content_available: true,
        notification: {
          body: "#{current_user.email} has accepted your friend request",
          title: "New Friend"
        }
      )
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
