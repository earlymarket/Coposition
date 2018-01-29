module Users::Approvals
  class CreateUserApproval
    include Interactor
    include Rails.application.routes.url_helpers

    delegate :current_user, :approvable, to: :context

    def call
      context.path = user_friends_path(user_id: current_user.id)
      if approval&.save
        context.approval = approval
        context.message = { notice: "Friend request sent" }
        create_activity
        send_notification
      else
        describe_error_case
        context.fail!
      end
    end

    private

    def create_activity
      CreateActivity.call(entity: approval, action: :create, owner: current_user, params: { approvable: approvable })
    end

    def send_notification
      Firebase::Push.call(
        topic: user.id,
        content_available: true,
        notification: {
          body: "#{current_user.email} has sent you a friend request",
          title: "New friend request"
        }
      )
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
      EmailRequest.create(user_id: current_user.id, email: approvable.downcase)
      UserMailer.invite_email(current_user, approvable).deliver_now
      UserMailer.invite_sent_email(current_user, approvable).deliver_now
    end

    def user
      @user ||= User.find_by(email: approvable.downcase)
    end

    def approval
      @approval ||= Approval.add_friend(current_user, user) if user
    end
  end
end
