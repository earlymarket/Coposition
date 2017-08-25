module Users::Approvals
  class CreateUserApproval
    include Interactor
    include Rails.application.routes.url_helpers

    delegate :current_user, :approvable, to: :context

    def call
      context.path = user_friends_path(user_id: current_user.id)
      if approval && approval.save
        context.message = { notice: "Friend request sent" }
        create_activity
      else
        describe_error_case
        context.fail!
      end
    end

    private

    def create_activity
      CreateActivity.call(entity: approval, action: :create, owner: current_user, params: { approvable: approvable })
    end

    def describe_error_case
      if user && approval
        context.message = { alert: "Error: #{approval.errors[:base].first}" }
        context.path = new_user_approval_path(user_id: current_user.id, approvable_type: "User")
      else
        invite_friend_email
        context.message = { notice: "User not signed up with Coposition, invite email sent!" }
      end
    end

    def invite_friend_email
      UserMailer.invite_email(approvable).deliver_now
    end

    def user
      @user ||= User.find_by(email: approvable.downcase)
    end

    def approval
      @approval ||= Approval.add_friend(current_user, user) if user
    end
  end
end
