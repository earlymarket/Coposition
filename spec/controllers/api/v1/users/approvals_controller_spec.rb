# require 'rails_helper'

# RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
#   include ControllerMacros

#   describe "developer submitting" do

#     before do
#       @user = FactoryGirl::create :user
#       @developer = FactoryGirl::create :developer
#       request.headers["X-Api-Key"] = @developer.api_key
#     end

#     it "should be able to submit an approval request" do
#       post :create, user_id: @user.username
#       binding.pry
#     end

#   end

# end