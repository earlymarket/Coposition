module ControllerMacros
  def create_user
    @request.env['devise.mapping'] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end

  def create_developer
    @request.env['devise.mapping'] = Devise.mappings[:developer]
    developer = FactoryGirl.create(:developer)
    sign_in developer
    developer
  end

  def res_hash
    # Check if it's a different request
    @json = nil if response != @res
    @json ||= begin
      json = JSON(response.body)
      json = JSON(response.body).symbolize_keys unless JSON(response.body).is_a? Array
      @res = response.dup
      json
    end
  end

  def api_request_headers(developer, user)
    request.headers['X-Api-Key'] = developer.api_key
    request.headers['X-User-Token'] = user.authentication_token
    request.headers['X-User-Email'] = user.email
  end
end
