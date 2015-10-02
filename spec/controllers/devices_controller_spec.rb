require 'rails_helper'

RSpec.describe Redbox::DevicesController, type: :controller do

  login_user

  it "should have a current_user" do
    # Test login_user
    expect(subject.current_user).to_not be nil
  end

  describe "posting" do

    before do
      @checkin = RedboxCheckin.create_from_string(RequestFixture.new.w_gps, add_device: true)
    end

    it "should POST to with an IMEI" do
      # For some reason, subject.current user was returning some weird results. Using last User instead
      @user = User.last
      post :create, device: { imei: @checkin.imei }
      
      expect(response.code).to eq "302"
      expect(@user.devices.count).to be 1
      expect(@user.devices.last).to eq @checkin.device
    end

  end

end
