require 'rails_helper'

RSpec.describe Users::DevicesController, type: :controller do

  login_user

  it "should have a current_user" do
    # Test login_user
    expect(subject.current_user).to_not be nil
  end

  describe "posting" do

    it "should POST to with a UUID" do
      # For some reason, subject.current user was returning some weird results. Using last User instead
      @device = Device.create
      @user = User.last
      post :create, {
      	user_id: @user.username,
      	device: { uuid: @device.uuid }
      }
      
      expect(response.code).to eq "302"
      expect(@user.devices.count).to be 1
      expect(@user.devices.last).to eq @device
    end

  end

end
