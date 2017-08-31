module Oauth
  class TokensController < Doorkeeper::ApplicationMetalController
    def create
      response = authorize_response
      headers.merge! response.headers
      self.response_body = response.body.to_json
      self.status        = response.status
    rescue Errors::DoorkeeperError => e
      handle_token_exception e
    end

    def revoke
      if authorized?
        User.find(token.resource_owner_id).approval_for(token.application.owner).update(status: "accepted")
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
