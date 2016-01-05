require 'rails_helper'

RSpec.describe Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:device) { FactoryGirl::create :device, user_id: user.id }
  let(:user) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user.devices << FactoryGirl::create(:device)
    user
  end
  let(:new_user) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end

end
