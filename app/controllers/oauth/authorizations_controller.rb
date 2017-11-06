module Oauth
  class AuthorizationsController < Doorkeeper::AuthorizationsController
    def create
      auth = authorization.authorize
      approve_application_owner auth
      redirect_or_render auth
    end

    private

    def approve_application_owner(authorization)
      return unless (application = authorization.pre_auth.client.application)
      return unless (developer = application.owner)

      developer.approvals.find_by(user_id: current_resource_owner.id).tap do |approval|
        approval ||= Approval.add_developer(current_resource_owner, developer)
        approval.complete!
      end
    end

    def pre_auth
      @pre_auth ||= Doorkeeper::OAuth::PreAuthorization.new(Doorkeeper.configuration,
                                                            server.client_via_uid,
                                                            params)
    end

    def authorization
      @authorization ||= strategy.request
    end

    def strategy
      @strategy ||= server.authorization_request pre_auth.response_type
    end

    def resource_owner_name
      current_resource_owner.username.exists? ? current_resource_owner.username : current_resource_owner.email
    end
    helper_method :resource_owner_name
  end
end
