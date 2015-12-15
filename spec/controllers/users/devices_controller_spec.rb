require 'rails_helper'

RSpec.describe Users::DevicesController, type: :controller do
  include ControllerMacros

  login_user

  it "should have a current_user" do
    # Test login_user
    expect(subject.current_user).to_not be nil
  end

  let(:empty_device) { Device.create }
  let(:device) { FactoryGirl::create :device }
  let(:user) { User.last }


  describe "posting" do


    it "should POST to with a UUID" do
      # For some reason, subject.current user was returning some weird results. Using last User instead
      post :create, {
      	user_id: user.username,
      	device: { 
          uuid: empty_device.uuid,
          name: "empty_device"
        }
      }
      
      expect(response.code).to eq "302"
      expect(user.devices.count).to be 1
      expect(user.devices.last).to eq empty_device
    end

    it "should switch fogging status to true by default" do
      expect(device.fogged?).to be false
      request.accept = "text/javascript"
      put :fog, {
        user_id: user.username,
        id: device.id
      }

      device.reload
      expect(device.fogged?).to be true
      
      request.accept = "text/javascript"
      put :fog, {
        user_id: user.username,
        id: device.id
      }

      device.reload
      expect(device.fogged?).to be false
    end

    it "should set a delay" do
      request.accept = "text/javascript"
      post :set_delay, {
        id: device.id,
        user_id: user.username,
        mins: 13
      }

      device.reload
      expect(device.delayed).to be 13
    end

    it "should switch privilege for a developer" do
      developer = FactoryGirl::create(:developer)
      device.developers << developer
      device.user = user
      device.save
      priv = device.privilege_for(developer)

      request.accept = "text/javascript"
      post :switch_privilege_for_developer, {
        id: device.id,
        user_id: user.username,
        developer: developer.id
      }

      expect(device.privilege_for(developer)).to_not be priv
    end

    it "should delete" do
      device.user = user
      device.save
      count = Device.count
      delete :destroy, { 
        user_id: user.username,
        id: device.id
      }

      expect(Device.count).to be count-1
    end


  end

end
