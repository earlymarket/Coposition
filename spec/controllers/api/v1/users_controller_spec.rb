require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
	include ControllerMacros

	before do
		@user = FactoryGirl::create :user
		@dev = FactoryGirl::create :developer
	end

	it "should require a valid API key" do
		get :index, nil
		# No API key supplied => Denied
		expect(response.status).to be 401

		request.headers["X-Api-Key"] = @dev.api_key[0..-2]
		get :index
		# API key supplied, but incorrect
		expect(response.status).to be 401


		request.headers["X-Api-Key"] = @dev.api_key
		get :index, format: :json
		expect(res_hash.first["username"]).to eq @user.username
	end
end
