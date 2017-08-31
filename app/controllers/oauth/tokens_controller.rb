module Oauth
  class TokensController < Doorkeeper::ApplicationMetalController
    def revoke
      if authorized?
        current_resource_owner.approval_for(token.application.owner).update("accepted")
        revoke_token
      end
      render json: {}, status: 200
    end

    private

    def authorized?
      return unless token.present?
      if token.application_id?
        server.client && server.client.application == token.application
      else
        true
      end
    end

    def revoke_token
      return unless token.accessible?
      token.revoke
    end

    def token
      @token ||= AccessToken.by_token(request.POST["token"]) || AccessToken.by_refresh_token(request.POST["token"])
    end

    def strategy
      @strategy ||= server.token_request params[:grant_type]
    end

    def authorize_response
      @authorize_response ||= strategy.authorize
    end
  end
end
