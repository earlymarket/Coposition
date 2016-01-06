module ControllerMacros

  def create_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
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

end