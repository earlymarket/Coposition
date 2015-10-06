require 'rails_helper'

RSpec.describe Api::V1::Users::DevicesController, type: :controller do
  include ControllerMacros


  describe "GET" do
    before do
    	@user = FactoryGirl::create :user
      @device = FactoryGirl::create :device
    	@developer = FactoryGirl::create :developer
    	@user.devices << @device
    	@user.save!
      @developer.request_approval_from(@user)
      @user.approve_developer(@developer)
      request.headers["X-Api-Key"] = @developer.api_key
  	end
		it "should GET a list of devices of a specific user" do
			get :index, user_id: @user.username, format: :json
      res = response_to_hash
      expect(res.first["id"]).to be @device.id
    end

    it "should GET information on a specific device for a specific user" do
      get :show, user_id: @user.username, id: @device.id, format: :json
      res = response_to_hash
      expect(res.first["id"]).to be @device.id
		end
	end

end