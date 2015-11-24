module ControllerMacros
  # def login_admin
  #   before(:each) do
  #     @request.env["devise.mapping"] = Devise.mappings[:admin]
  #     sign_in FactoryGirl.create(:admin) # Using factory girl as an example
  #   end
  # end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
    end
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