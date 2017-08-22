module ControllerMacros
  extend ActiveSupport::Concern

  def create_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = create(:user)
    sign_in user
    user
  end

  def create_developer
    @request.env["devise.mapping"] = Devise.mappings[:developer]
    developer = create(:developer)
    sign_in developer
    developer
  end

  def res_hash
    # Check if it"s a different request
    if response != @res
      @res = response.dup
      json = JSON(response.body)
      json = json.symbolize_keys unless json.is_a? Array
      json
    end
  end

  def api_request_headers(developer, user)
    request.headers["HTTP_AUTHORIZATION"] =
      "Bearer #{Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public').token}"
    request.headers["X-Api-Key"] = developer.api_key
    request.headers["X-User-Token"] = user.authentication_token
    request.headers["X-User-Email"] = user.email
  end
end
