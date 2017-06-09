module Doorkeeper
  class AuthorizationsController < Doorkeeper::ApplicationController
    def create
      auth = authorization.authorize
      approve_application_owner auth
      redirect_or_render auth
    end

    private

    def approve_application_owner(authorization)
      return unless (application = authorization.grant.application)
      return unless (developer = application.owner)

      developer.approvals
        .find_by(user_id: current_resource_owner.id)
        .update_column(status: "complete")
    end
  end
end
